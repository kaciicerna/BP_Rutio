//
//  SearchedTrasController.swift
//  Rutio
//
//  Created by Kateřina Černá on 31.01.2021.
//

import UIKit
import CoreData
import Alamofire


class SearchedTrasController: UITableViewController {
    
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var planning: PlanningTrasController? {
        didSet{
            loadJsonData()
        }
    }
    var planningFavourite: FavouriteController?
    
    @IBAction func cancelSearch(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private var jsonFrom: [From] = []
    var nameFrom: String = ""
    // var data: [Any] = []
    var data: Itinerary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        /*let nibName = UINib(nibName: "SearchTableViewCellDetail", bundle: nil)
         tableView.register(nibName, forCellReuseIdentifier: "SearchTableViewCellDetail")*/
        tableView.register(UINib(nibName: "SearchTableViewCellDetail", bundle: Bundle(for: SearchTableViewCell.self)), forCellReuseIdentifier: "SearchTableViewCellDetail")
        
        
        let epochTime = TimeInterval(1429162809359) / 1000
        let date = Date(timeIntervalSince1970: epochTime)   // "Apr 16, 2015, 2:40 AM"
        print("Converted Time \(date)")
        
        
        
    }
    
    func loadJsonData()
    {
        //print(planning)
        let url = URL(string:"https://api.rutio.eu/otp/routers/zagreb/plan?fromPlace=\(planning?.startDestination.latitude ?? 0.0),\(planning?.startDestination.longitude ?? 0.0)&toPlace=\(planning?.endDestination.latitude ?? 0.0),\(planning?.endDestination.longitude ?? 0.0)&date=2020/12/15&time=11:46&showIntermediateStops=true&maxWalkDistance=300&wheelchair=false&mode=TRANSIT&useRequestedDateTimeInMaxHours=true&optimize=TRANSFERS&walkReluctance=20&min=TRIANGLE&triangleTimeFactor=1&triangleSlopeFactor=0&searchWindow=14400&allowBikeRental=true&arriveBy=false")
        print(url)
        
        let headers: HTTPHeaders = ["Content-Type" : "application/json; charset=utf-8"]
        Alamofire.request(url ?? "", method: .get ,headers: headers).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let parResult = try JSONDecoder().decode(Welcome.self, from: data)
                    print(parResult)
                    //self.data.append(parResult.plan)
                    self.data = parResult.plan.itineraries.first
                    
                    self.tableView.reloadData()
                    print(self.jsonFrom)
                } catch {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getSpecificDateFormat(format: String) -> String {
        return Date().getDateInFormat(format: format)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let itinerary = self.data else {
            return 0
        }
        
        if itinerary.legs.count < 1 {
            // create the alert
            let alert = UIAlertController(title: "No transport connection found".localized(), message: "You must re-enter the start and end stops.".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "I understand".localized(), style: .cancel, handler: nil))
            
            return 0
        }
        
        return itinerary.legs.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCellDetail", for: indexPath) as? SearchTableViewCell,
            let itinerary = self.data
        else {
            return UITableViewCell()
        }
        
        //let item = data[indexPath.row]
        
        cell.commonInit(leg: itinerary.legs[indexPath.row])
        return cell
        
        /*
        switch item {
        case let from as Plan:
            //let n = Int()
            //from.itineraries.count
            
            let transportType: TransportType = .transit
            
            cell.trasnsportImage.image = UIImage(named: transportType.imageName)
            //cell.trasnsportImage = from.itineraries[0].legs[0].mode
            if #available(iOS 15.0, *) {
                cell.commonInit(
                    date: from.date,
                    start: from.from.name,
                    destination: from.to.name,
                    number: Int((from.itineraries[0].legs[0].routeShortName)!)!,
                    timeStart: from.itineraries[0].startTime,
                    timeDestination: from.itineraries[0].endTime,
                    walk: "Go "+String(from.itineraries[0].walkDistance)+" m on foot")
            } else {
                // Fallback on earlier versions
            }
            return cell
        default:
            fatalError()
        }
         */
    }
}

extension Int {
    func convertToDate() -> Date {
        return Date(timeIntervalSince1970: TimeInterval(self) / 1_000)
    }
}
extension NSDate {
    func localizedStringTime()->String {
        return DateFormatter.localizedString(from: self as Date, dateStyle: DateFormatter.Style.none, timeStyle: DateFormatter.Style.short)
    }
}


extension UIView {
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
