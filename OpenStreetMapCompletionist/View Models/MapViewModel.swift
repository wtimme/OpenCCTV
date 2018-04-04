//
//  MapViewModel.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/4/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import MapKit

import SwiftOverpass

class MapViewModel: NSObject {
    
    var region: MKCoordinateRegion? {
        didSet {
            if let region = region {
                ensureDataIsPresent(for: region)
            }
        }
    }
    
    private let maximumSearchRadiusInMeters: Double
    
    init(maximumSearchRadiusInMeters: Double) {
        self.maximumSearchRadiusInMeters = maximumSearchRadiusInMeters
    }
    
    private func ensureDataIsPresent(for region: MKCoordinateRegion) {
        let north = CLLocation(latitude: region.center.latitude - region.span.latitudeDelta * 0.5, longitude: region.center.longitude)
        let south = CLLocation(latitude: region.center.latitude + region.span.latitudeDelta * 0.5, longitude: region.center.longitude)
        let northSouthDistanceInMeters = north.distance(from: south)
        
        let east = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude - region.span.longitudeDelta * 0.5)
        let west = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude + region.span.longitudeDelta * 0.5)
        let eastWestDistanceInMeters = east.distance(from: west)
        
        guard northSouthDistanceInMeters < maximumSearchRadiusInMeters, eastWestDistanceInMeters < maximumSearchRadiusInMeters else {
            print("Won't query Overpass: N-S distance is \(northSouthDistanceInMeters) and E-W distance is \(eastWestDistanceInMeters)")
            return
        }

        // TODO: Query
//        let query = SwiftOverpass.query(type: .node)
//        query.setBoudingBox(s: 53.584245, n: 53.607651, w: 10.013931, e: 10.072253)
//        query.hasTag("amenity", equals: "bicycle_parking")
//        //        query.doesNotHaveTag("capacity")
//        query.tags["capacity"] = OverpassTag(key: "capacity", value: ".", isNegation: true, isRegex: true)
//
//        SwiftOverpass.api(endpoint: "https://overpass-api.de/api/interpreter")
//            .fetch(query) { (response) in
//
//        }
    }

}

extension MapViewModel: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        region = mapView.region
    }
    
}
