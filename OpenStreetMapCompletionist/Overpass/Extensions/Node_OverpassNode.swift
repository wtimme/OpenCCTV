//
//  Node_OverpassNode.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/23/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import SwiftOverpass

import CoreLocation

extension Node {
    init?(swiftOverpassNode: OverpassNode) {
        guard let id = Int(swiftOverpassNode.id) else {
            return nil
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: swiftOverpassNode.latitude, longitude: swiftOverpassNode.longitude)
        guard CLLocationCoordinate2DIsValid(coordinate) else {
            return nil
        }
        
        self.id = id
        self.coordinate = coordinate
        self.rawTags = swiftOverpassNode.tags
        self.version = nil
    }
}
