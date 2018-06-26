//
//  BoundingBox_MKCoordinateRegion.swift
//  OpenStreetMapCompletionistTests
//
//  Created by Wolfgang Timme on 4/24/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import MapKit

/// An area on the map.
///
/// It can be used to query the OpenStreetMap API:
/// https://wiki.openstreetmap.org/wiki/API_v0.6#Retrieving_map_data_by_bounding_box:_GET_.2Fapi.2F0.6.2Fmap
struct BoundingBox {
    let left: Double
    let bottom: Double
    let right: Double
    let top: Double
}

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
