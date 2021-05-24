//
//  Selfie.swift
//  SelfieGram
//
//  Created by Ferry Adi Wijayanto on 05/11/19.
//  Copyright © 2019 Ferry Adi Wijayanto. All rights reserved.
//

import UIKit.UIImage
import CoreLocation.CLLocation

class Selfie: Codable {
    let created: Date
    let id: UUID
    
    var title = "New Selfie!"
    var image: UIImage? {
        get {
            return SelfieStore.shared.getImage(id: self.id)
        }
        set {
            try? SelfieStore.shared.setImage(id: self.id, image: newValue ?? UIImage())
        }
    }
    
    var position: Coordinate?
    
    struct Coordinate: Codable, Equatable {
        var latitude: Double
        var longitude: Double
        
        public static func == (lhs: Selfie.Coordinate, rhs: Selfie.Coordinate) -> Bool {
            return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
        }
        
        var location: CLLocation {
            get {
                return CLLocation(latitude: latitude, longitude: longitude)
            }
            set {
                self.longitude = newValue.coordinate.longitude
                self.latitude = newValue.coordinate.latitude
            }
        }
        
        init(location: CLLocation) {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
        }
    }
    
    init(title: String) {
        self.title = title
        self.created = Date()
        self.id = UUID()
    }
}
