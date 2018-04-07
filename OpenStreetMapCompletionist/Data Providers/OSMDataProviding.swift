//
//  OSMDataProviding.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/7/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

import MapKit
import SwiftOverpass

protocol OSMDataProviding: class {
    func ensureDataIsPresent(for region: MKCoordinateRegion)
}

class OverpassOSMDataProvider: NSObject, OSMDataProviding {
    init(interpreterURL: URL, maximumSearchRadiusInMeters: Double) {
        self.interpreterURL = interpreterURL
        self.maximumSearchRadiusInMeters = maximumSearchRadiusInMeters
    }

    // MARK: Private

    private let interpreterURL: URL
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

        SwiftOverpass.api(endpoint: interpreterURL.absoluteString)
            .fetch(query) { response in
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

        NotificationCenter.default.post(name: .osmDataProviderDidAddAnnotations,
                                        object: annotations)
    }

    // MARK: OSMDataProviding

    func ensureDataIsPresent(for region: MKCoordinateRegion) {
        guard !doesRegionExceedMaximumSearchRadius(region) else {
            print("Won't query Overpass for this region.")
            return
        }

        queryOverpassForNodes(in: region)
    }
}

extension Notification.Name {
    static let osmDataProviderDidAddAnnotations = Notification.Name("osmDataProviderDidAddAnnotations")
}

extension OverpassNode: Hashable {
    public static func == (lhs: OverpassNode, rhs: OverpassNode) -> Bool {
        return lhs.id == rhs.id
    }

    public var hashValue: Int {
        return Int(id)!
    }
}
