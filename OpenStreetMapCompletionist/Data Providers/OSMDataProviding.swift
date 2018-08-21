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
    
    func nodes(region: MKCoordinateRegion, _ completion: @escaping ([Node]) -> Void)
    
    func node(id: Int) -> Node?
    
    func ensureDataIsPresent(for region: MKCoordinateRegion)
    
    /// Indicates whether there are API requests in progress.
    var areRequestsInProgress: Bool { get }
}

class OverpassOSMDataProvider: NSObject, OSMDataProviding {
    init(interpreterURL: URL, downloadStrategy: OSMDataDownloadStrategy) {
        self.interpreterURL = interpreterURL
        self.downloadStrategy = downloadStrategy
    }

    // MARK: Private

    private let interpreterURL: URL
    private let downloadStrategy: OSMDataDownloadStrategy
    private var discoveredNodes = Set<Node>()
    
    private var numberOfRequestsInProgress = 0 {
        didSet {
            guard numberOfRequestsInProgress != oldValue else { return }
            
            NotificationCenter.default.post(name: .osmDataProviderDidUpdateRequestsInProgress,
                                            object: self)
        }
    }

    private func processDownloadedNodes(_ nodes: [Node]) {
        let newNodes = Set(nodes).subtracting(discoveredNodes)
        discoveredNodes = discoveredNodes.union(newNodes)
        
        let annotations = newNodes.compactMap { (node) -> MKAnnotation? in
            OverpassNodeAnnotation(node: node)
        }

        NotificationCenter.default.post(name: .osmDataProviderDidAddAnnotations,
                                        object: annotations)
    }

    // MARK: OSMDataProviding
    
    func nodes(region: MKCoordinateRegion, _ completion: @escaping ([Node]) -> Void) {
        /// TODO: Query
        let query = SwiftOverpass.query(type: .node)
        query.setBoudingBox(s: region.center.latitude - region.span.latitudeDelta * 0.5,
                            n: region.center.latitude + region.span.latitudeDelta * 0.5,
                            w: region.center.longitude - region.span.longitudeDelta * 0.5,
                            e: region.center.longitude + region.span.longitudeDelta * 0.5)
        query.hasTag("man_made", equals: "surveillance")
        query.hasTag("surveillance:type", equals: "camera")
        
        numberOfRequestsInProgress += 1

        SwiftOverpass.api(endpoint: interpreterURL.absoluteString)
            .fetch(query, verbosity: .meta) { response in
                self.numberOfRequestsInProgress -= 1
                
                guard let swiftOverpassNodes = response.nodes else {
                    completion([])
                    return
                }

                // Create our own objects from the nodes.
                let nodes = swiftOverpassNodes.compactMap { Node(swiftOverpassNode: $0) }
                
                completion(nodes)
        }
    }

    func ensureDataIsPresent(for region: MKCoordinateRegion) {
        guard downloadStrategy.allowsDownload(of: region) else {
            print("Won't query Overpass: Download strategy doesn't allow a region of this size.")
            return
        }
        
        nodes(region: region) { nodes in
            self.processDownloadedNodes(nodes)
        }
    }

    func node(id: Int) -> Node? {
        return discoveredNodes.first(where: { $0.id == id })
    }
    
    var areRequestsInProgress: Bool {
        return 0 < numberOfRequestsInProgress
    }
}

extension Notification.Name {
    static let osmDataProviderDidAddAnnotations = Notification.Name("osmDataProviderDidAddAnnotations")
    static let osmDataProviderDidUpdateRequestsInProgress = Notification.Name("osmDataProviderDidUpdateRequestsInProgress")
}
