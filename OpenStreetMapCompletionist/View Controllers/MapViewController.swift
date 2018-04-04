//
//  MapViewController.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/4/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import UIKit

import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let viewModel = MapViewModel(maximumSearchRadiusInMeters: 2000)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = viewModel
    }
}
