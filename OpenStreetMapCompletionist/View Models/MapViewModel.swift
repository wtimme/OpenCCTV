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
    
    let locationProvider: LocationProviding
    
    weak var delegate: MapViewModelDelegate?
    
    var hasIssuesDeterminingDeviceLocation: Bool {
        if case .denied = locationProvider.authorizationStatus {
            return true
        }
        
        if case .restricted = locationProvider.authorizationStatus {
            return true
        }
        
        return false
    }
    
    init(locationProvider: LocationProviding,
         maximumSearchRadiusInMeters: Double) {
        self.locationProvider = locationProvider
        self.maximumSearchRadiusInMeters = maximumSearchRadiusInMeters
        
        super.init()
        
        locationProvider.delegate = self
    }
    
    // MARK: Private
    
    private let maximumSearchRadiusInMeters: Double
    
    private var discoveredNodes = Set<OverpassNode>()
    
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
        locationProvider.deviceLocation { [weak self] (location, error) in
            if let locationError = error as? LocationError, case .denied = locationError  {
                self?.delegate?.askCustomerToOpenLocationSettings()
            } else if let deviceLocation = location {
                let span = MKCoordinateSpanMake(0.025, 0.025)
                let region = MKCoordinateRegionMake(deviceLocation.coordinate, span)
                
                // As we got a location, we can safely assume that we have the permissions
                // and display the user location on the map.
                self?.delegate?.setMapViewShowsUserLocation(true)
                
                self?.delegate?.updateMapViewRegion(region)
            } else {
                print("Failed to determine the current position: \(error.debugDescription)")
            }
        }
    }
    
    func centerMapOnDeviceRegionIfAuthorized() {
        guard locationProvider.authorizationStatus == .authorizedAlways || locationProvider.authorizationStatus == .authorizedWhenInUse else {
            // We don't want the permission dialog to show up, so we stop here.
            return
        }
        
        centerMapOnDeviceRegion()
    }

}

extension MapViewModel: LocationProviderDelegate {
    
    func locationProviderDidRecognizeAuthorizationStatusChange(_ authorizationStatus: CLAuthorizationStatus) {
        print("Authorization status changed to \(authorizationStatus)")
        
        switch authorizationStatus {
            case .authorizedAlways:
                centerMapOnDeviceRegion()
                break
            case .authorizedWhenInUse:
                centerMapOnDeviceRegion()
                break
        default:
            // Ignore
            break
        }
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
