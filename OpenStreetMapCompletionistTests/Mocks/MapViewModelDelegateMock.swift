//
//  MapViewModelDelegateMock.swift
//  OpenStreetMapCompletionistTests
//
//  Created by Wolfgang Timme on 4/7/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

import MapKit

@testable import OpenStreetMapCompletionist

class MapViewModelDelegateMock: NSObject, MapViewModelDelegate {
    
    var numberOfUpdateNetworkActivityIndicatorVisibilityCalls = 0
    
    // MARK: MapViewModelDelegate
    
    var mapViewRegion: MKCoordinateRegion?

    func updateMapViewRegion(_ region: MKCoordinateRegion) {
        mapViewRegion = region
    }

    func setMapViewShowsUserLocation(_: Bool) {}

    func addAnnotations(_: [MKAnnotation]) {}

    func askCustomerToOpenLocationSettings() {}

    func indicateTroubleWithLocation(_: Bool) {}
    
    func updateNetworkActivityIndicatorVisibility() {
        numberOfUpdateNetworkActivityIndicatorVisibilityCalls += 1
    }
}
