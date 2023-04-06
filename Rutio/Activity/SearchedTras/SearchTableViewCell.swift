//
//  SearchTableViewCell.swift
//  Rutio
//
//  Created by Kateřina Černá on 02.04.2021.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    static let identifier = "SearchTableViewCellDetail"
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var trasnsportImage: UIImageView!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var destiantionTime: UILabel!
    @IBOutlet weak var walkLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        startLabel.text = nil
        
        destinationLabel.text = nil
        
        numberLabel.text = nil
        
        startTime.text = nil
        
        destiantionTime.text = nil
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    
    func commonInit(leg: Leg) {
        let timeFormat = Int(leg.duration)/60 % 60
        timeLabel.text = String("\(timeFormat) min")
        startLabel.text = leg.from.name
        destinationLabel.text = leg.to.name
        numberLabel.text = leg.routeShortName
        startTime.text = leg.startTime.convertToDate().getDateInFormat(format: "hh:mm")
        destiantionTime.text = leg.endTime.convertToDate().getDateInFormat(format: "hh:mm")
        
        let mode = TransportType(rawValue: leg.mode) ?? .walk
        trasnsportImage.image = UIImage(named: mode.imageName)
    }
    
    
    /*func commonInit(date: Int,start: String, destination: String, number: Int,  timeStart: Int, timeDestination: Int, walk: String) {
        dateLabel.text = date.convertToDate().getDateInFormat(format: "dd.MM.yyyy")
        startLabel.text = start
        destinationLabel.text = destination
        numberLabel.text = String(number)
        startTime.text = timeStart.convertToDate().getDateInFormat(format: "hh:mm")
        destiantionTime.text = timeDestination.convertToDate().getDateInFormat(format: "hh:mm")
        
        if (walk) != nil {
            walkLabel.text = walk
            walkLabel.isHidden = false
            
        } else {
            walkLabel.isHidden = true
        }
    }*/
    
    
}

enum TransportType: String, Identifiable {
    
    case bus = "BUS"
    case train = "TRAIN"
    case tram = "TRAM"
    case bicycle = "BICYCLE"
    case transit = "TRANSIT"
    case walk = "WALK"
    
    var id: String {
        UUID().uuidString
    }
    
    var imageName: String {
        switch self {
        case .bus:
            return "ic_bus"
        case .train:
            return "ic_train"
        case .tram:
            return "ic_tram"
        case .bicycle:
            return "ic_bikeshare"
        case .transit:
            return "ic_tram"
        case .walk:
            return "ic_walk"
        }
    }
}
