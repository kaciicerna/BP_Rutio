//
//  StopResponce.swift
//  Rutio
//
//  Created by Kateřina Černá on 21.02.2021.
//

import UIKit
import CoreData

struct StopResponse: Decodable {
    var plan : Plan2
}


struct Plan2: Decodable {
    var  from: [From2] = [From2]()

    let id = UUID()
    let date: Int?
    
    mutating func filterData(string: String) {
        self.from = self.from.filter({ (from) -> Bool in
                    return false
                })
            }
    
    func getDateFormat() -> Date? {
        guard let dateFormat = date else{ return nil }
        return Date(timeIntervalSince1970: TimeInterval(dateFormat * 1_000 / 1_000))
    }
    
    private enum PlanKey: String, CodingKey {
        case date = "date"
        
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PlanKey.self)
        date = try container.decode(Int.self, forKey: .date)
    }
    
}


struct From2: Decodable {
    let id = UUID()
    let name: String
    var lon : Double = 0
    var lat : Double = 0
    
    private enum PlanKey: String, CodingKey {
        case name = "name"
        case lat = "lat"
        case lon = "lon"
        
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PlanKey.self)
        name = try container.decode(String.self, forKey: .name)
        lat = try container.decode(Double.self, forKey: .lat)
        lon = try container.decode(Double.self, forKey: .lon)
    }
    
    
}


extension Date {
    func getDateInFormat(format: String) -> String {
        let date = self
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}

extension TimeInterval {
  func format() -> String? {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.day, .hour, .minute, .second, .nanosecond]
    formatter.unitsStyle = .abbreviated
    formatter.maximumUnitCount = 1
    return formatter.string(from: self)
  }
}

