//
//  MapViewController.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/4/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import UIKit

import MapKit
import SwiftIcons
import SwiftLocation
import SafariServices

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var centerOnDeviceLocationBarButtonItem: UIBarButtonItem!
    
    private var viewModel: MapViewModelProtocol = MapViewModel(locationProvider: LocationProvider(locatorManager: Locator),
                                                               maximumSearchRadiusInMeters: 4000)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        viewModel.delegate = self
        
        viewModel.centerMapOnDeviceRegionIfAuthorized()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedAnnotation = mapView.selectedAnnotations.first {
            mapView.deselectAnnotation(selectedAnnotation, animated: animated)
        }
    }
    
    @IBAction func didTapCenterOnDeviceLocationBarButtonItem(_: AnyObject) {
        viewModel.centerMapOnDeviceRegion()
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Let the view model know about the new region.
        viewModel.ensureDataIsPresent(for: mapView.region)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? OverpassNodeAnnotation {
            guard let nodeURL = URL(string: "https://www.openstreetmap.org/node/\(annotation.nodeId)") else {
                return
            }
            
            let safariViewController = SFSafariViewController(url: nodeURL)
            present(safariViewController, animated: true, completion: nil)
        }
        
    }
    
}

extension MapViewController: MapViewModelDelegate {
    
    func updateMapViewRegion(_ region: MKCoordinateRegion) {
        mapView.setRegion(region, animated: true)
    }
    
    func setMapViewShowsUserLocation(_ showsUserLocation: Bool) {
        mapView.showsUserLocation = showsUserLocation
    }
    
    func addAnnotations(_ annotations: [MKAnnotation]) {
        mapView.addAnnotations(annotations)
    }
    
    func askCustomerToOpenLocationSettings() {
        let alertController = UIAlertController(title: "Unable to access the device location", message: "Go to your app settings and manually change the permission to \"While Using The App\" to allow access to our device location.", preferredStyle: .alert)
        
        let openSettingsAction = UIAlertAction(title: "Go to Settings", style: .default) { (_) in
            self.openAppSettings()
        }
        alertController.addAction(openSettingsAction)
        
        let okayAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func openAppSettings() {
        guard let url = URL(string:UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func indicateTroubleWithLocation(_ hasTrouble: Bool) {
        let iconColor: UIColor
        if hasTrouble {
            iconColor = .red
        } else {
            iconColor = navigationController?.navigationBar.tintColor ?? .black
        }
        
        centerOnDeviceLocationBarButtonItem.setIcon(icon: .mapicons(.locationArrow), iconSize: 30, color: iconColor)
    }
    
}
