//
//  LocationProvider.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/5/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import CoreLocation

import SwiftLocation

protocol LocationProviding {
    var authorizationStatus: CLAuthorizationStatus { get }
}

class LocationProvider: NSObject, LocationProviding {
    
    let locatorManager: LocatorManager
    
    init(locatorManager: LocatorManager) {
        self.locatorManager = locatorManager
    }
    
    // MARK: LocationProviding
    
    var authorizationStatus: CLAuthorizationStatus {
        return locatorManager.authorizationStatus
    }

}
