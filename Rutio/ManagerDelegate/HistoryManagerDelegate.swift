//
//  HistoryManagerDelegate.swift
//  Rutio
//
//  Created by Kateřina Černá on 03.02.2021.
//

import UIKit
import CoreData

protocol HistoryManagerDelegate {
    func insertHistory(start: String, destination: String)
}
