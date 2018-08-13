//
//  BoundingBox.swift
//  OSMSwift
//
//  Created by Wolfgang Timme on 7/15/18.
//

import Foundation

public struct BoundingBox {
    let left: Double // The longitude of the left (westernmost) side of the bounding box
    let bottom: Double // The latitude of the bottom (southernmost) side of the bounding box
    let right: Double // The longitude of the right (easternmost) side of the bounding box
    let top: Double // The latitude of the top (northernmost) side of the bounding box
    
    public init(left: Double, bottom: Double, right: Double, top: Double) {
        self.left = left
        self.bottom = bottom
        self.right = right
        self.top = top
    }
    
    /// The String representation of the bounding box when using it as an URL parameter.
    public var queryString: String {
        return "\(left),\(bottom),\(right),\(top)"
    }
}
