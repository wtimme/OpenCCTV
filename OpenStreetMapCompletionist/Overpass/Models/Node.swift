//
//  Node.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/8/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

import CoreLocation

struct Node: Hashable {
    let id: Int
    let coordinate: CLLocationCoordinate2D
    let rawTags: [(key: String, value: String?)]

    // MARK: Hashable

    public static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.id == rhs.id
    }

    public var hashValue: Int {
        return id
    }
}
