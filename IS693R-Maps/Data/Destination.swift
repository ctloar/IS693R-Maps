//
//  Destination.swift
//  IS693R-Maps
//
//  Created by Cade Loar on 8/22/24.
//

import Foundation
import SwiftData

@Model
final class Destination {
    var dateVisited: Date
    var name: String
    var address: String
    var city: String
    var country: String
    // var identifier: String
    var latitude: Double
    var longitude: Double
    
    init(dateVisited: Date, name: String, address: String, city: String, country: String, latitude: Double, longitude: Double) {
        self.dateVisited = dateVisited
        self.name = name
        self.address = address
        self.city = city
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
    }
}
