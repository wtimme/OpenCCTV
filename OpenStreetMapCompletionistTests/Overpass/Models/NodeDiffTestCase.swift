//
//  NodeDiffTestCase.swift
//  OpenStreetMapCompletionistTests
//
//  Created by Wolfgang Timme on 4/15/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import XCTest

@testable import OpenStreetMapCompletionist
import CoreLocation

class NodeDiffTestCase: XCTestCase {
    
    func testDesignatedInitializer() {
        let nodeId = 42
        let addedTags = ["new": "tag"]
        let updatedTags = ["updated": "tag"]
        let removedTags = ["removed": "tag"]
        
        let diff = NodeDiff(nodeId: nodeId,
                            addedTags: addedTags,
                            updatedTags: updatedTags,
                            removedTags: removedTags)
        
        XCTAssertEqual(diff.nodeId, nodeId)
        XCTAssertEqual(diff.addedTags, addedTags)
        XCTAssertEqual(diff.updatedTags, updatedTags)
        XCTAssertEqual(diff.removedTags, removedTags)
    }
    
    func testConvenienceInitializerShouldUseTheIdOfTheUpdatedNode() {
        let node = Node(id: 1,
                        coordinate: CLLocationCoordinate2DMake(53.553100, 10.006700),
                        rawTags: ["some_tag": "some value"],
                        version: nil)
        
        let diff = NodeDiff(node: node, originalNode: nil)
        
        XCTAssertEqual(diff.nodeId, node.id)
    }
    
    func testDiffWithoutOriginalNodeShouldReportAllTagsAsNew() {
        let node = Node(id: 1,
                        coordinate: CLLocationCoordinate2DMake(53.553100, 10.006700),
                        rawTags: ["some_tag": "some value"],
                        version: nil)
        
        let diff = NodeDiff(node: node, originalNode: nil)
        
        XCTAssertEqual(diff.addedTags, node.rawTags)
        XCTAssertEqual(diff.updatedTags, [:])
        XCTAssertEqual(diff.removedTags, [:])
    }
    
    func testDiffWithOriginalNodeShouldReportNewTagsAsAdded() {
        let originalNode = Node(id: 1,
                                coordinate: CLLocationCoordinate2DMake(53.553100, 10.006700),
                                rawTags: ["old_tag": "some value"],
                                version: 9)
        
        let updatedNode = Node(id: 1,
                               coordinate: CLLocationCoordinate2DMake(53.553100, 10.006700),
                               rawTags: ["old_tag": "some value",
                                         "new_tag": "some value"],
                               version: 9)
        
        let diff = NodeDiff(node: updatedNode, originalNode: originalNode)
        
        XCTAssertEqual(diff.addedTags, ["new_tag": "some value"])
    }
    
    func testDiffWithOriginalNodeShouldReportExistingTagsWithNewValueAsUpdated() {
        let originalNode = Node(id: 1,
                                coordinate: CLLocationCoordinate2DMake(53.553100, 10.006700),
                                rawTags: ["old_tag": "some value"],
                                version: 9)
        
        let updatedNode = Node(id: 1,
                               coordinate: CLLocationCoordinate2DMake(53.553100, 10.006700),
                               rawTags: ["old_tag": "a new value"],
                               version: 9)
        
        let diff = NodeDiff(node: updatedNode, originalNode: originalNode)
        
        XCTAssertEqual(diff.updatedTags, ["old_tag": "a new value"])
    }
    
    func testDiffWithOriginalNodeShouldReportTagsThatNoLongerExistAsRemoved() {
        let originalNode = Node(id: 1,
                                coordinate: CLLocationCoordinate2DMake(53.553100, 10.006700),
                                rawTags: ["old_tag": "some value"],
                                version: 9)
        
        let updatedNode = Node(id: 1,
                               coordinate: CLLocationCoordinate2DMake(53.553100, 10.006700),
                               rawTags: [:],
                               version: 9)
        
        let diff = NodeDiff(node: updatedNode, originalNode: originalNode)
        
        XCTAssertEqual(diff.removedTags, ["old_tag": "some value"])
    }
    
}
