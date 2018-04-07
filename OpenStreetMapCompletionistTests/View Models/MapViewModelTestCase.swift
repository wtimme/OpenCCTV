//
//  MapViewModelTestCase.swift
//  OpenStreetMapCompletionistTests
//
//  Created by Wolfgang Timme on 4/5/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import XCTest

import CoreLocation

@testable import OpenStreetMapCompletionist

class MapViewModelTestCase: XCTestCase {
    
    var locationProviderMock: LocationProviderMock!
    var viewModelDelegateMock: MapViewModelDelegateMock!
    var viewModel: MapViewModel!
    
    override func setUp() {
        super.setUp()
        
        locationProviderMock = LocationProviderMock()
        viewModelDelegateMock = MapViewModelDelegateMock()
        
        viewModel = MapViewModel(locationProvider: locationProviderMock,
                                 maximumSearchRadiusInMeters: 4000)
        viewModel.delegate = viewModelDelegateMock
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
        let deviceCoordinate = CLLocationCoordinate2DMake(53.553100, 10.006700)
        locationProviderMock.mockedDeviceLocationCoordinate = deviceCoordinate
        
        viewModel.locationProviderDidRecognizeAuthorizationStatusChange(.authorizedWhenInUse)
        
        guard let mapViewRegion = viewModelDelegateMock.mapViewRegion else {
            XCTFail("The view model delegate should've been notified about the device coordinate")
            return
        }
        
        
        XCTAssertTrue(canCoordinatesConsideredToBeEqual(mapViewRegion.center, deviceCoordinate))
    }
    
}

extension XCTestCase {
    
    func canCoordinatesConsideredToBeEqual(_ cllc2d1: CLLocationCoordinate2D, _ cllc2d2: CLLocationCoordinate2D) -> Bool {
        let epsilon = 0.005
        
        return fabs(cllc2d1.latitude - cllc2d2.latitude) <= epsilon && fabs(cllc2d1.longitude - cllc2d2.longitude) <= epsilon
    }
    
}
