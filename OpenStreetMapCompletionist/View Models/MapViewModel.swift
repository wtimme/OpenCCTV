//
//  MapViewModel.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/4/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import MapKit

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

    func regionDidChange(_ region: MKCoordinateRegion)

    /// Flag on whether the view model has issues determining the device location.
    var hasIssuesDeterminingDeviceLocation: Bool { get }

    /// Centers the map on the device location. Will trigger the permission dialog if necessary.
    func centerMapOnDeviceRegion()

    /// Centers the map on the device location, if the customer authorized us to access the location.
    func centerMapOnDeviceRegionIfAuthorized()
}

class MapViewModel: NSObject, MapViewModelProtocol {

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
         osmDataProvider: OSMDataProviding,
         notificationCenter: NotificationCenter = .default) {
        self.locationProvider = locationProvider
        self.osmDataProvider = osmDataProvider

        super.init()

        locationProvider.delegate = self

        notificationCenter.addObserver(self,
                                       selector: #selector(didReceiveOSMDataProviderAddedAnnotationsNotification(_:)),
                                       name: .osmDataProviderDidAddAnnotations,
                                       object: nil)
    }
    
    // MARK: Private
    
    private let locationProvider: LocationProviding
    private let osmDataProvider: OSMDataProviding

    // MARK: MapViewModelProtocol

    func regionDidChange(_ region: MKCoordinateRegion) {
        osmDataProvider.ensureDataIsPresent(for: region)
    }

    func centerMapOnDeviceRegion() {
        locationProvider.deviceLocation { [weak self] location, error in
            if let locationError = error as? LocationError, case .denied = locationError {
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

    // MARK: Notifications

    @objc func didReceiveOSMDataProviderAddedAnnotationsNotification(_ note: Notification) {
        guard let annotations = note.object as? [MKAnnotation] else {
            return
        }

        delegate?.addAnnotations(annotations)
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
