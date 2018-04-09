//
//  OSMDataDownloadStrategy.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/10/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

import MapKit

struct OSMDataDownloadStrategy {
    let maximumRadiusInMeters: Double

    func allowsDownload(of region: MKCoordinateRegion) -> Bool {
        let north = CLLocation(latitude: region.center.latitude - region.span.latitudeDelta * 0.5, longitude: region.center.longitude)
        let south = CLLocation(latitude: region.center.latitude + region.span.latitudeDelta * 0.5, longitude: region.center.longitude)
        let northSouthDistanceInMeters = north.distance(from: south)

        let east = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude - region.span.longitudeDelta * 0.5)
        let west = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude + region.span.longitudeDelta * 0.5)
        let eastWestDistanceInMeters = east.distance(from: west)

        guard northSouthDistanceInMeters < maximumRadiusInMeters, eastWestDistanceInMeters < maximumRadiusInMeters else {
            print("Region exceeds maximum radius (\(maximumRadiusInMeters): N-S distance is \(northSouthDistanceInMeters) and E-W distance is \(eastWestDistanceInMeters)")
            return false
        }

        return true
    }
}

protocol RegionDownloadLimiting {
    func shouldDownloadData(for region: MKCoordinateRegion) -> Bool
}

class RegionDownloadLimiter: NSObject {
}
