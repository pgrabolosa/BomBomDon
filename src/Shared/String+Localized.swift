//
//  File.swift
//  BOAB
//
//  Created by Pierre Grabolosa on 22/11/2020.
//

import Foundation
import os.log

extension String {
    var localized: String {
        return Bundle.main.localizedString(forKey: self, value: self, table: nil)
    }
}
