//
//  Map.swift
//  Rutio
//
//  Created by Kateřina Černá on 18.11.2020.
//

import UIKit
import MapKit
import CoreData
import CoreLocation


class MapController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var currentLocationStr = "Current location"
    @IBOutlet weak private var mapTypeControl: UISegmentedControl!

    private var pointJson = [From2]()
    var tappedMarker = MKMapView()
    let x = 150.000000 //X
    let y = 35.000000  //Y
    let lat = 45.74
    let lon = 15.95
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initLocationManager()
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        // Check for Location Services
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            
            //Zoom to user location
            if let userLocation = locationManager.location?.coordinate {
                let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
                mapView.setRegion(viewRegion, animated: false)
            }
            
            DispatchQueue.main.async {
                self.locationManager.startUpdatingLocation()
            }
            
        }
        
        mapView.delegate = self
        mapView.mapType = .standard
        ///ukáže provoz
        //mapView.showsTraffic = true
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.register(AnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        
        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
        let homeLocation = CLLocation(latitude: 45.81881, longitude: 15.95882)
        centerMapOnLocation(location: homeLocation)
        
        loadStopData()
    }
    
    func centerMapOnLocation(location: CLLocation)
    {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: 50000, longitudinalMeters: 50000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func loadStopData(){
        guard let mapUrl = URL(string: "https://api.rutiozagreb.com/stops/") else { return }
        URLSession.shared.dataTask(with: mapUrl) { (data, response, error) in
            
            if error == nil {
                do {
                    self.pointJson = try JSONDecoder().decode([From2].self, from: data!)
                    
                    DispatchQueue.main.async {
                        
                        for state in self.pointJson {
                            print(state.lat, state.lon, state.name)
                            
                            let lat = Double(state.lat)
                            let long = Double(state.lon)

                            //markers work correctly
                            let annotation = CustomePinAnnotation()
                            annotation.coordinate = CLLocationCoordinate2DMake(lat, long)
                            annotation.title = state.name
                            annotation.subtitle = state.name
                            annotation.pinImage = "pin_map"
                            self.mapView.addAnnotation(annotation)
                            self.mapView.delegate = self
                        }
                    }
                } catch let jsonError{
                    print("An error occurred + \(jsonError)")
                }
            }
        }.resume()
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
        _ = MKPointAnnotation()
        if locations.last != nil{
            let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
            self.mapView.setRegion(region, animated: true)
        }
        // Get user's Current Location and Drop a pin
        let mUserLocation:CLLocation = locations[0] as CLLocation
        _ = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)
    }
    
    @IBAction func mapTypeControl(_ sender: UISegmentedControl) {
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
            mapTypeControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        } else {
            mapTypeControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        }
        
        mapTypeControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
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
}
