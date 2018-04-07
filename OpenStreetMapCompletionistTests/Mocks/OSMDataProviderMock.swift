//
//  OSMDataProviderMock.swift
//  OpenStreetMapCompletionistTests
//
//  Created by Wolfgang Timme on 4/7/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

import MapKit
@testable import OpenStreetMapCompletionist

class OSMDataProviderMock: NSObject, OSMDataProviding {
    var lastRegionToEnsureDataFor: MKCoordinateRegion?

    func ensureDataIsPresent(for region: MKCoordinateRegion) {
        lastRegionToEnsureDataFor = region
    }
}
