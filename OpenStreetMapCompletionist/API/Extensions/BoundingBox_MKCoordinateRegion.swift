//
//  BoundingBox_MKCoordinateRegion.swift
//  OpenStreetMapCompletionistTests
//
//  Created by Wolfgang Timme on 4/24/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import MapKit

extension BoundingBox {
    
    /// Creates a bounding box from the given region.
    ///
    /// - Parameter region: The region to create the bounding box from.
    init(region: MKCoordinateRegion) {
        let northWestCorner = CLLocationCoordinate2D(latitude: region.center.latitude  - (region.span.latitudeDelta  / 2.0),
                                                     longitude: region.center.longitude + (region.span.longitudeDelta / 2.0))
        
        let southEastCorner = CLLocationCoordinate2D(latitude: region.center.latitude  + (region.span.latitudeDelta  / 2.0),
                                                     longitude: region.center.longitude - (region.span.longitudeDelta / 2.0))
        
        self.left = min(northWestCorner.longitude, southEastCorner.longitude)
        self.bottom = min(northWestCorner.latitude, southEastCorner.latitude)
        self.right = max(northWestCorner.longitude, southEastCorner.longitude)
        self.top = max(northWestCorner.latitude, southEastCorner.latitude)
    }
    
}
