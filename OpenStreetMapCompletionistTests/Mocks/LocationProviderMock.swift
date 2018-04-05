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
    
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

}
