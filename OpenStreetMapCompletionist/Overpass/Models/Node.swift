//
//  Node.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/8/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

import CoreLocation

struct Node {
    let id: Int
    let coordinate: CLLocationCoordinate2D
    let tags: [String: String]
}
