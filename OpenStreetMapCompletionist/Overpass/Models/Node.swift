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
    let rawTags: [String: String]
    let version: Int?

    // MARK: Hashable

    public static func == (lhs: Node, rhs: Node) -> Bool {
        guard lhs.id == rhs.id else { return false }
        
        guard lhs.rawTags.count == rhs.rawTags.count else { return false }
        
        for (key, value) in lhs.rawTags {
            guard rhs.rawTags[key] == value else { return false }
        }
        
        guard lhs.version == rhs.version else { return false }
        
        return true
    }

    public var hashValue: Int {
        return id
    }
}
