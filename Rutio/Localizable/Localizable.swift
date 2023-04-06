//
//  Localizable.swift
//  Rutio
//
//  Created by Kateřina Černá on 27.07.2021.
//

import UIKit

extension String{
    func localized()-> String {
        return NSLocalizedString(self, tableName: "Localize",bundle: .main, value: self ,comment: self)
    }
}
