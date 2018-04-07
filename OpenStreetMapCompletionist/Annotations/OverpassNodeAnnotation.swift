//
//  OverpassNodeAnnotation.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/5/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import MapKit

import SwiftOverpass

class OverpassNodeAnnotation: NSObject, MKAnnotation {
    let nodeId: Int
    let coordinate: CLLocationCoordinate2D

    init?(node: OverpassNode) {
        guard let nodeId = Int(node.id) else {
            return nil
        }

        self.nodeId = nodeId
        coordinate = CLLocationCoordinate2D(latitude: node.latitude, longitude: node.longitude)
    }
}
