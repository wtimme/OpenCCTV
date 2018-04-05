//
//  MapViewModelTestCase.swift
//  OpenStreetMapCompletionistTests
//
//  Created by Wolfgang Timme on 4/5/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import XCTest

@testable import OpenStreetMapCompletionist

class MapViewModelTestCase: XCTestCase {
    
    var viewModel: MapViewModel!
    var locationProviderMock: LocationProviderMock!
    
    override func setUp() {
        super.setUp()
        
        locationProviderMock = LocationProviderMock()
        viewModel = MapViewModel(locationProvider: locationProviderMock,
                                 maximumSearchRadiusInMeters: 4000)
    }
    
    override func tearDown() {
        viewModel = nil
        
        super.tearDown()
    }
    
    func testViewModelShouldNotReportIssuesDeterminingDeviceLocationWhenAuthorizationStatusIsAuthorized() {
        locationProviderMock.authorizationStatus = .authorizedAlways
        XCTAssertFalse(viewModel.hasIssuesDeterminingDeviceLocation)
        
        locationProviderMock.authorizationStatus = .authorizedWhenInUse
        XCTAssertFalse(viewModel.hasIssuesDeterminingDeviceLocation)
    }
    
    func testViewModelShouldNotReportIssuesDeterminingDeviceLocationWhenAuthorizationStatusIsNotDetermined() {
        locationProviderMock.authorizationStatus = .notDetermined
        XCTAssertFalse(viewModel.hasIssuesDeterminingDeviceLocation)
    }
    
    func testViewModelShouldReportIssuesDeterminingDeviceLocationWhenAuthorizationWasDeniedOrIsRestricted() {
        locationProviderMock.authorizationStatus = .restricted
        XCTAssertTrue(viewModel.hasIssuesDeterminingDeviceLocation)
        
        locationProviderMock.authorizationStatus = .denied
        XCTAssertTrue(viewModel.hasIssuesDeterminingDeviceLocation)
    }
    
    func testViewModelShouldTellDelegateToCenterOnDeviceLocationWhenAuthorizationStatusChangesToAuthorizedWhenInUse() {
        
    }
    
}
