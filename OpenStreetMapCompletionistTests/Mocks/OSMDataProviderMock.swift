//
//  OSMDataProviderMock.swift
//  OpenStreetMapCompletionistTests
//
//  Created by Wolfgang Timme on 4/7/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

import MapKit
@testable import OpenStreetMapCompletionist

class OSMDataProviderMock: NSObject, OSMDataProviding {
    
    var region: MKCoordinateRegion?
    var nodes = [Node]()
    
    func nodes(region: MKCoordinateRegion, _ completion: @escaping ([Node]) -> Void) {
        completion(nodes)
    }

    func ensureDataIsPresent(for region: MKCoordinateRegion) {
        self.region = region
    }

    func node(id: Int) -> Node? {
        return nodes.first(where: { return $0.id == id })
    }
}
