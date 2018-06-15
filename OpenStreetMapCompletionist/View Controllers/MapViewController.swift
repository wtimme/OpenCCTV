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
import Presentr

class MapViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var centerOnDeviceLocationBarButtonItem: UIBarButtonItem!

    private let dataProvider: OSMDataProviding
    private let changeHandler: OSMChangeHandling
    private let viewModel: MapViewModelProtocol
    
    let presenter: Presentr = {
        let width = ModalSize.fluid(percentage: 0.9)
        let height = ModalSize.fluid(percentage: 0.40)
        let customType = PresentationType.custom(width: width, height: height, center: .center)
        
        let customPresenter = Presentr(presentationType: customType)
        customPresenter.transitionType = .coverVertical
        customPresenter.roundCorners = true
        customPresenter.keyboardTranslationType = .compress
        
        return customPresenter
    }()

    required init?(coder aDecoder: NSCoder) {
        dataProvider = OverpassOSMDataProvider(interpreterURL: URL(string: "https://overpass-api.de/api/interpreter")!,
                                               downloadStrategy: OSMDataDownloadStrategy(maximumRadiusInMeters: 6500))
        
        changeHandler = InMemoryChangeHandler(osmDataProvider: dataProvider)
        
        let viewModel = MapViewModel(locationProvider: LocationProvider(locatorManager: Locator),
                                     osmDataProvider: dataProvider)
        self.viewModel = viewModel

        super.init(coder: aDecoder)

        viewModel.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self

        viewModel.centerMapOnDeviceRegionIfAuthorized()
        centerOnDeviceLocationBarButtonItem.setIcon(icon: .mapicons(.locationArrow), iconSize: 20)

        mapView.register(NodeAnnotationView.self, forAnnotationViewWithReuseIdentifier: NodeAnnotationView.reuseIdentifier)

        positionMapAttributionLabel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedAnnotation = mapView.selectedAnnotations.first {
            mapView.deselectAnnotation(selectedAnnotation, animated: animated)
        }
    }

    /// Makes sure that the "Legal" label at the bottom left corner of the map is correctly positioned on iPhone X.
    /// With the map view being fullscreen, the label's position is too far down on the iPhone X.
    private func positionMapAttributionLabel() {
        additionalSafeAreaInsets = UIEdgeInsetsMake(0.0, 0.0, 1.0, 0.0)
    }

    @IBAction func didTapCenterOnDeviceLocationBarButtonItem(_: AnyObject) {
        viewModel.centerMapOnDeviceRegion()
    }

    @IBAction func didTapOpenStreetMapCopyrightButton(_: AnyObject) {
        let safariViewController = SFSafariViewController(url: URL(string: "https://www.openstreetmap.org/copyright")!)

        present(safariViewController, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if
            segue.identifier == "ShowNodeDetails",
            let selectedNode = sender as? Node,
            let destinationNavigationController = segue.destination as? UINavigationController,
            let formViewController = destinationNavigationController.topViewController as? NodeFormViewController {
            formViewController.changeHandler = changeHandler
            
            if let updatedNode = changeHandler.get(id: selectedNode.id) {
                formViewController.node = updatedNode
            } else {
                formViewController.node = selectedNode
            }
        } else if
            segue.identifier == "ShowChanges",
            let destinationNavigationController = segue.destination as? UINavigationController,
            let changesViewController = destinationNavigationController.topViewController as? ChangesViewController {
            changesViewController.changeHandler = changeHandler
            changesViewController.nodeDataProvider = dataProvider
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func presentCard(for node: Node) {
        
        guard let capacityEditorViewController = storyboard?.instantiateViewController(withIdentifier: "CapacityEditorViewController") as? CapacityEditorViewController else { return }
        
        if let updatedNode = changeHandler.get(id: node.id) {
            capacityEditorViewController.node = updatedNode
        } else {
            capacityEditorViewController.node = node
        }
        
        capacityEditorViewController.changeHandler = changeHandler
        capacityEditorViewController.delegate = self
        
        let navigationController = UINavigationController(rootViewController: capacityEditorViewController)
        
        customPresentViewController(presenter, viewController: navigationController, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated _: Bool) {
        // Let the view model know about the new region.
        viewModel.regionDidChange(mapView.region)
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if
            let annotation = view.annotation as? OverpassNodeAnnotation,
            let node = dataProvider.node(id: annotation.nodeId) {
            presentCard(for: node)
            
            mapView.deselectAnnotation(annotation, animated: false)
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            // Use the default annotation for the user location
            return nil
        }

        return mapView.dequeueReusableAnnotationView(withIdentifier: NodeAnnotationView.reuseIdentifier, for: annotation)
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

        let openSettingsAction = UIAlertAction(title: "Go to Settings", style: .default) { _ in
            self.openAppSettings()
        }
        alertController.addAction(openSettingsAction)

        let okayAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alertController.addAction(okayAction)

        present(alertController, animated: true, completion: nil)
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(url) else {
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

extension MapViewController: CapacityEditorViewControllerDelegate {
    func showDetails(for node: Node, andAdd key: String?) {
        presentedViewController?.dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "ShowNodeDetails", sender: node)
        })
    }
}
