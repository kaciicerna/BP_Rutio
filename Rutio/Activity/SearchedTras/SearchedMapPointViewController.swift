//
//  SearchedMapPointViewController.swift
//  Rutio
//
//  Created by Kateřina Černá on 26.03.2021.
//

import UIKit
import MapKit
import CoreData
import CoreLocation
import Alamofire


class SearchMapPointController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var currentLocationStr = "Current location"
    @IBOutlet weak var typeMapView: UISegmentedControl!
    
    private var pointJson = [From2]()
    var tappedMarker = MKMapView()
    let x = 150.000000
    let y = 35.000000
    let lat = 45.74
    let lon = 15.95
    var planning: PlanningTrasController?
    
    var data: [Any] = []
    var myRoute : MKRoute?
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
        self.locationManager.requestAlwaysAuthorization()
        
        // setup mapView if nil
        setupMapView()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }        // Do any additional setup after loading the view.

        
        let homeLocation = CLLocation(latitude: 45.81881, longitude: 15.95882)
        centerMapOnLocation(location: homeLocation)
        
        loadJsonMapData()
    }
    
    func setupMapView() {
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
    }
    
    func centerMapOnLocation(location: CLLocation)
    {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: 30000, longitudinalMeters: 30000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func loadJsonMapData()
    {
        let url = URL(string:"https://api.rutio.eu/otp/routers/zagreb/plan?fromPlace=\(planning?.startDestination.latitude ?? 0.0),\(planning?.startDestination.longitude ?? 0.0)&toPlace=\(planning?.endDestination.latitude ?? 0.0),\(planning?.endDestination.longitude ?? 0.0)&date=2020/12/15&time=11:46&showIntermediateStops=true&maxWalkDistance=300&wheelchair=false&mode=TRANSIT&useRequestedDateTimeInMaxHours=true&optimize=TRANSFERS&walkReluctance=20&min=TRIANGLE&triangleTimeFactor=1&triangleSlopeFactor=0&searchWindow=14400&allowBikeRental=true&arriveBy=false")!
        
        
        let headers: HTTPHeaders = ["Content-Type" : "application/json; charset=utf-8"]
        Alamofire.request(url , method: .get ,headers: headers).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    
                    let parResult = try JSONDecoder().decode(Welcome.self, from: data)
                    print(parResult)
                    //self.data.append(parResult.plan.to)
                    //self.data.append(parResult.plan.itineraries)
                    let lat = Double(parResult.plan.from.lat)
                    let long = Double(parResult.plan.from.lon)
                    let lat2 = Double(parResult.plan.to.lat)
                    let long2 = Double(parResult.plan.to.lon)
                    
                    //markers work correctly
                    let firstAnnotation = CustomePinAnnotation()
                    firstAnnotation.coordinate = CLLocationCoordinate2DMake(lat, long)
                    firstAnnotation.title = parResult.plan.from.name
                    firstAnnotation.subtitle = "Number: \(parResult.plan.itineraries[0].legs[0].routeShortName!)"
                    firstAnnotation.pinImage = "pin_map"
                    firstAnnotation.pinColor = UIColor.red
                    self.mapView.addAnnotation(firstAnnotation)
                    
                    let secondAnnotation = CustomePinAnnotation()
                    secondAnnotation.coordinate = CLLocationCoordinate2DMake(lat2, long2)
                    secondAnnotation.title = parResult.plan.to.name
                    secondAnnotation.subtitle = "Number: \(parResult.plan.itineraries[0].legs[0].routeShortName!)"
                    secondAnnotation.pinImage = "pin_map"
                    self.mapView.addAnnotation(secondAnnotation)
                    self.mapView.delegate = self
                    
                    let points = [CLLocationCoordinate2DMake(lat, long), CLLocationCoordinate2DMake(lat2, long2)]
                    let geodesic = MKGeodesicPolyline(coordinates: points, count: 2)
                    self.mapView.addOverlay(geodesic)
                    
                } catch {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Errors " + error.localizedDescription)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let _:CLLocationCoordinate2D = manager.location!.coordinate
        self.mapView.showsUserLocation = true
        
        mapView.mapType = MKMapType.standard
        let annotation = MKPointAnnotation()
        if locations.last != nil{
            let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
            self.mapView.setRegion(region, animated: true)
        }
        // Get user's Current Location and Drop a pin
        let mUserLocation:CLLocation = locations[0] as CLLocation
        let center = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
    }
    
    @IBAction func typeMapViewButton(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            mapView.mapType = .hybrid
            changeMapTypeControlColorHybrid(isHybrid: true)
        default:
            mapView.mapType = .standard
            changeMapTypeControlColorHybrid(isHybrid: false)
        }
    }
    func changeMapTypeControlColorHybrid(isHybrid: Bool) {
        if isHybrid {
            typeMapView.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        } else {
            typeMapView.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        }
        typeMapView.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
    }
    
    
    func setUsersClosestLocation(mLattitude: CLLocationDegrees, mLongitude: CLLocationDegrees) -> String {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: mLattitude, longitude: mLongitude)
        
        geoCoder.reverseGeocodeLocation(location) {
            (placemarks, error) -> Void in
            
            if let mPlacemark = placemarks{
                if let dict = mPlacemark[0].addressDictionary as? [String: Any]{
                    if let Name = dict["Name"] as? String{
                        if let City = dict["City"] as? String{
                            self.currentLocationStr = Name + ", " + City
                        }
                    }
                }
            }
        }
        return currentLocationStr
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = UIColor.red
            renderer.lineWidth = 3
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = Bundle.main.bundleIdentifier! + ".AnnotationView"
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        
        annotationView.canShowCallout = true
        if annotation is MKUserLocation {
            return nil
        } else if annotation is CustomePinAnnotation {
            annotationView.image =  resizeImage(uiImage: UIImage(imageLiteralResourceName: "pin_map"), targetSize: CGSize(width: 40, height: 40))
            return annotationView
        } else {
            return nil
        }
    }
    
    func resizeImage(uiImage: UIImage?, targetSize: CGSize) -> UIImage {
        
        guard let image = uiImage else { return UIImage() }
        
        let size = image.size
        
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
