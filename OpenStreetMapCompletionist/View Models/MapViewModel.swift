//
//  MapViewModel.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/4/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import MapKit

import SwiftOverpass
import SwiftLocation

protocol MapViewModelDelegate: class {
    
    // Interact with the map view
    func updateMapViewRegion(_ region: MKCoordinateRegion)
    func setMapViewShowsUserLocation(_ showsUserLocation: Bool)
    
    /// The customer needs to change the location settings for our app manually.
    func askCustomerToOpenLocationSettings()
    
    /// Indicate whether there is an issue with the location currently.
    ///
    /// - Parameter hasTrouble: Flag whether the app had problems determining the device location.
    func indicateTroubleWithLocation(_ hasTrouble: Bool)
    
}

class MapViewModel: NSObject {
    
    weak var delegate: MapViewModelDelegate?
    
    public private(set) var hasIssuesDeterminingDeviceLocation = false {
        didSet {
            delegate?.indicateTroubleWithLocation(hasIssuesDeterminingDeviceLocation)
        }
    }
    
    public func ensureDataIsPresent(for region: MKCoordinateRegion) {
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
        
        /// TODO: Query
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
    
    public func centerMapOnDeviceRegion() {
        Locator.currentPosition(accuracy: .room, onSuccess: { [weak self] (location) in
            let span = MKCoordinateSpanMake(0.025, 0.025)
            let region = MKCoordinateRegionMake(location.coordinate, span)
            
            // As we got a location, we can safely assume that we have the permissions
            // and display the user location on the map.
            self?.delegate?.setMapViewShowsUserLocation(true)
            
            self?.delegate?.updateMapViewRegion(region)
        }) { [weak self] (error, lastKnownLocation) in
            self?.hasIssuesDeterminingDeviceLocation = true
            
            switch(error) {
            case .denied:
                self?.delegate?.askCustomerToOpenLocationSettings()
                break;
            default:
                print("Failed to determine the current position: \(error)")
            }
        }
    }
    
    private let maximumSearchRadiusInMeters: Double
    
    private var locationAuthorizationEventToken: LocatorManager.Events.Token?
    
    init(maximumSearchRadiusInMeters: Double) {
        self.maximumSearchRadiusInMeters = maximumSearchRadiusInMeters
        
        super.init()
        
        locationAuthorizationEventToken = Locator.events.listen { [weak self] authorizationStatus in
            print("Authorization status changed to \(authorizationStatus)")
            
            switch authorizationStatus {
            case .authorizedAlways:
                self?.hasIssuesDeterminingDeviceLocation = false
                self?.centerMapOnDeviceRegion()
                break
            case .authorizedWhenInUse:
                self?.hasIssuesDeterminingDeviceLocation = false
                self?.centerMapOnDeviceRegion()
                break
            default:
                self?.hasIssuesDeterminingDeviceLocation = true
                break
            }
        }
    }
    
    deinit {
        if let token = locationAuthorizationEventToken {
            Locator.events.remove(token: token)
        }
    }

}
