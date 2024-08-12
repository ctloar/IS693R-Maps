//
//  Item.swift
//  IS693R-Maps
//
//  Created by Cade Loar on 8/12/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
