//
//  LocationProviderMock.swift
//  OpenStreetMapCompletionistTests
//
//  Created by Wolfgang Timme on 4/5/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

@testable import OpenStreetMapCompletionist
import CoreLocation

class LocationProviderMock: NSObject, LocationProviding {
    
    var mockedDeviceLocationCoordinate: CLLocationCoordinate2D?
    var mockedError: Error?
    
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    var delegate: LocationProviderDelegate?
    
    func deviceLocation(_ completion: @escaping (CLLocation?, Error?) -> Void) {
        let location: CLLocation?
        if let deviceCoordinate = mockedDeviceLocationCoordinate {
            location = CLLocation(latitude: deviceCoordinate.latitude, longitude: deviceCoordinate.longitude)
        } else {
            location = nil
        }
        
        completion(location, mockedError)
    }

}
