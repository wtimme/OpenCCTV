//
//  OverpassNodeAnnotation.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/5/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import MapKit

class OverpassNodeAnnotation: NSObject, MKAnnotation {
    let nodeId: Int
    let coordinate: CLLocationCoordinate2D

    init?(node: Node) {
        nodeId = node.id
        coordinate = node.coordinate
    }
}
