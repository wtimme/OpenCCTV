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

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var centerOnDeviceLocationBarButtonItem: UIBarButtonItem!
    
    private let viewModel = MapViewModel(maximumSearchRadiusInMeters: 2000)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        centerOnDeviceLocationBarButtonItem.setIcon(icon: .mapicons(.locationArrow), iconSize: 30, color: navigationController?.navigationBar.tintColor ?? .black)
    }
    
    @IBAction func didTapCenterOnDeviceLocationBarButtonItem(_: AnyObject) {
        viewModel.centerMapOnDeviceRegion()
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Let the view model know about the new region.
        viewModel.region = mapView.region
    }
    
}
