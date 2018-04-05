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
    func addAnnotations(_ annotations: [MKAnnotation])
    
    /// The customer needs to change the location settings for our app manually.
    func askCustomerToOpenLocationSettings()
    
    /// Indicate whether there is an issue with the location currently.
    ///
    /// - Parameter hasTrouble: Flag whether the app had problems determining the device location.
    func indicateTroubleWithLocation(_ hasTrouble: Bool)
    
}

protocol MapViewModelProtocol {
    
    var delegate: MapViewModelDelegate? { get set }
    
    /// Flag on whether the view model has issues determining the device location.
    var hasIssuesDeterminingDeviceLocation: Bool { get }
    
    /// Centers the map on the device location. Will trigger the permission dialog if necessary.
    func centerMapOnDeviceRegion()
    
    /// Centers the map on the device location, if the customer authorized us to access the location.
    func centerMapOnDeviceRegionIfAuthorized()
    
    func ensureDataIsPresent(for region: MKCoordinateRegion)
}

class MapViewModel: NSObject, MapViewModelProtocol {
    
    weak var delegate: MapViewModelDelegate?
    
    var hasIssuesDeterminingDeviceLocation: Bool = false {
        didSet {
            delegate?.indicateTroubleWithLocation(hasIssuesDeterminingDeviceLocation)
        }
    }
    
    init(maximumSearchRadiusInMeters: Double, locatorManager: LocatorManager) {
        self.maximumSearchRadiusInMeters = maximumSearchRadiusInMeters
        self.locatorManager = locatorManager
        
        super.init()
        
        startListeningForLocationAuthorizationStatusEvents()
    }
    
    deinit {
        if let token = locationAuthorizationEventToken {
            locatorManager.events.remove(token: token)
        }
    }
    
    // MARK: Private
    
    private let maximumSearchRadiusInMeters: Double
    private let locatorManager: LocatorManager
    private var locationAuthorizationEventToken: LocatorManager.Events.Token?
    
    private var discoveredNodes = Set<OverpassNode>()
    
    private func startListeningForLocationAuthorizationStatusEvents() {
        locationAuthorizationEventToken = locatorManager.events.listen { [weak self] authorizationStatus in
            print("Authorization status changed to \(authorizationStatus)")
            
            switch authorizationStatus {
            case .denied:
                self?.hasIssuesDeterminingDeviceLocation = true
                break
            case .restricted:
                self?.hasIssuesDeterminingDeviceLocation = true
                break
            case .authorizedAlways:
                self?.hasIssuesDeterminingDeviceLocation = false
                self?.centerMapOnDeviceRegion()
                break
            case .authorizedWhenInUse:
                self?.hasIssuesDeterminingDeviceLocation = false
                self?.centerMapOnDeviceRegion()
                break
            case .notDetermined:
                // We haven't asked the customer for permissions yet. This is not an issue.
                self?.hasIssuesDeterminingDeviceLocation = false
                break
            }
        }
    }
    
    private func doesRegionExceedMaximumSearchRadius(_ region: MKCoordinateRegion) -> Bool {
        let north = CLLocation(latitude: region.center.latitude - region.span.latitudeDelta * 0.5, longitude: region.center.longitude)
        let south = CLLocation(latitude: region.center.latitude + region.span.latitudeDelta * 0.5, longitude: region.center.longitude)
        let northSouthDistanceInMeters = north.distance(from: south)
        
        let east = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude - region.span.longitudeDelta * 0.5)
        let west = CLLocation(latitude: region.center.latitude, longitude: region.center.longitude + region.span.longitudeDelta * 0.5)
        let eastWestDistanceInMeters = east.distance(from: west)
        
        guard northSouthDistanceInMeters < maximumSearchRadiusInMeters, eastWestDistanceInMeters < maximumSearchRadiusInMeters else {
            print("Region exceeds maximum search radius (\(maximumSearchRadiusInMeters): N-S distance is \(northSouthDistanceInMeters) and E-W distance is \(eastWestDistanceInMeters)")
            return true
        }
        
        return false
    }
    
    private func queryOverpassForNodes(in region: MKCoordinateRegion) {
        /// TODO: Query
        let query = SwiftOverpass.query(type: .node)
        query.setBoudingBox(s: region.center.latitude - region.span.latitudeDelta * 0.5,
                            n: region.center.latitude + region.span.latitudeDelta * 0.5,
                            w: region.center.longitude - region.span.longitudeDelta * 0.5,
                            e: region.center.longitude + region.span.longitudeDelta * 0.5)
        query.hasTag("amenity", equals: "bicycle_parking")
        //        query.doesNotHaveTag("capacity")
        query.tags["capacity"] = OverpassTag(key: "capacity", value: ".", isNegation: true, isRegex: true)
        
        SwiftOverpass.api(endpoint: "https://overpass-api.de/api/interpreter")
            .fetch(query) { (response) in
                guard let nodes = response.nodes else {
                    return
                }
                
                self.addNodesToMapView(nodes)
        }
    }
    
    private func addNodesToMapView(_ nodes: [OverpassNode]) {
        let newNodes = Set(nodes).subtracting(discoveredNodes)
        discoveredNodes = discoveredNodes.union(newNodes)
        
        let annotations = newNodes.compactMap { (node) -> MKAnnotation? in
            OverpassNodeAnnotation(node: node)
        }
        
        delegate?.addAnnotations(annotations)
    }
    
    // MARK: MapViewModelProtocol
    
    func ensureDataIsPresent(for region: MKCoordinateRegion) {
        guard !doesRegionExceedMaximumSearchRadius(region) else {
            print("Won't query Overpass for this region.")
            return
        }
        
        queryOverpassForNodes(in: region)
    }
    
    func centerMapOnDeviceRegion() {
        locatorManager.currentPosition(accuracy: .room, onSuccess: { [weak self] (location) in
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
    
    func centerMapOnDeviceRegionIfAuthorized() {
        guard locatorManager.authorizationStatus == .authorizedAlways || locatorManager.authorizationStatus == .authorizedWhenInUse else {
            // We don't want the permission dialog to show up, so we stop here.
            return
        }
        
        centerMapOnDeviceRegion()
    }

}

extension OverpassNode: Hashable {
    
    public static func ==(lhs: OverpassNode, rhs: OverpassNode) -> Bool {
        return lhs.id == rhs.id
    }
    
    public var hashValue: Int {
        return Int(self.id)!
    }
    
}
