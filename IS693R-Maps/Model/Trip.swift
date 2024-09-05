//
//  Trip.swift
//  IS693R-Maps
//
//  Created by Cade Loar on 8/31/24.
//

import Foundation
import SwiftData

@Model
final class Trip {
    var title: String
    var timestamp: Date
    var destinations: [Destination] = []
    
    init(title: String, timestamp: Date, destinations: [Destination]) {
        self.title = title
        self.timestamp = timestamp
        self.destinations = destinations
    }
}
