//
//  LocationProvider.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/5/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import CoreLocation

import SwiftLocation

protocol LocationProviderDelegate: class {
    
    func locationProviderDidRecognizeAuthorizationStatusChange(_ authorizationStatus: CLAuthorizationStatus)
    
}

protocol LocationProviding: class {
    
    var authorizationStatus: CLAuthorizationStatus { get }
    
    var delegate: LocationProviderDelegate? { get set }
    
    func deviceLocation(_ completion: @escaping (CLLocation?, Error?) -> Void)
    
}

class LocationProvider: NSObject, LocationProviding {
    
    private let locatorManager: LocatorManager
    private var locationAuthorizationEventToken: LocatorManager.Events.Token?
    
    init(locatorManager: LocatorManager) {
        self.locatorManager = locatorManager
        
        super.init()
        
        startListeningForLocationAuthorizationStatusEvents()
    }
    
    deinit {
        if let token = locationAuthorizationEventToken {
            locatorManager.events.remove(token: token)
        }
    }
    
    private func startListeningForLocationAuthorizationStatusEvents() {
        locationAuthorizationEventToken = locatorManager.events.listen { [weak self] authorizationStatus in
            self?.delegate?.locationProviderDidRecognizeAuthorizationStatusChange(authorizationStatus)
        }
    }
    
    // MARK: LocationProviding
    
    weak var delegate: LocationProviderDelegate?
    
    var authorizationStatus: CLAuthorizationStatus {
        return locatorManager.authorizationStatus
    }
    
    func deviceLocation(_ completion: @escaping (CLLocation?, Error?) -> Void) {
        locatorManager.currentPosition(accuracy: .room, onSuccess: { (location) in
            completion(location, nil)
        }) { (error, lastKnownLocation) in
            completion(lastKnownLocation, error)
        }
    }

}
