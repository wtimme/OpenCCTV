//
//  NodeTestCase.swift
//  OpenStreetMapCompletionistTests
//
//  Created by Wolfgang Timme on 4/14/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import XCTest

@testable import OpenStreetMapCompletionist
import CoreLocation

class NodeTestCase: XCTestCase {
    
    func testNodeShouldNotBeConsideredEqualIfTheyHaveDifferentKeys() {
        let nodeId = 1
        let coordinate = CLLocationCoordinate2DMake(53.553100, 10.006700)
        let version = 2
        
        let firstNode = Node(id: nodeId,
                             coordinate: coordinate,
                             rawTags: ["1": "some value"],
                             version: version)
        
        let secondNode = Node(id: nodeId,
                              coordinate: coordinate,
                              rawTags: ["2": "some value"],
                              version: version)
        
        XCTAssertNotEqual(firstNode, secondNode)
    }
    
    func testNodeShouldNotBeConsideredEqualIfTheyHaveDifferentValues() {
        let nodeId = 1
        let coordinate = CLLocationCoordinate2DMake(53.553100, 10.006700)
        let version = 2
        
        let firstNode = Node(id: nodeId,
                             coordinate: coordinate,
                             rawTags: ["1": "some value"],
                             version: version)
        
        let secondNode = Node(id: nodeId,
                              coordinate: coordinate,
                              rawTags: ["2": "a different value"],
                              version: version)
        
        XCTAssertNotEqual(firstNode, secondNode)
    }
    
    func testNodeShouldNotBeConsideredEqualIfTheyHaveDifferentNumberOfTags() {
        let nodeId = 1
        let coordinate = CLLocationCoordinate2DMake(53.553100, 10.006700)
        let version = 2
        
        let firstNode = Node(id: nodeId,
                             coordinate: coordinate,
                             rawTags: ["1": "some value"],
                             version: version)
        
        let secondNode = Node(id: nodeId,
                              coordinate: coordinate,
                              rawTags: ["1": "some value", "2": "another value"],
                              version: version)
        
        XCTAssertNotEqual(firstNode, secondNode)
    }
    
    // MARK: Version
    
    func testNodeShouldNotBeConsideredEqualIfTheyHaveDifferentVersions() {
        let nodeId = 1
        let coordinate = CLLocationCoordinate2DMake(53.553100, 10.006700)
        let rawTags = ["1": "some value"]
        
        let firstNode = Node(id: nodeId,
                             coordinate: coordinate,
                             rawTags: rawTags,
                             version: 9)
        
        let secondNode = Node(id: nodeId,
                              coordinate: coordinate,
                              rawTags: rawTags,
                              version: nil)
        
        XCTAssertNotEqual(firstNode, secondNode)
    }
    
}
