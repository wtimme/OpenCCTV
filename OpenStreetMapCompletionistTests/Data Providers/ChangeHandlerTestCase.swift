//
//  ChangeHandlerTestCase.swift
//  OpenStreetMapCompletionistTests
//
//  Created by Wolfgang Timme on 4/15/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import XCTest

@testable import OpenStreetMapCompletionist
import CoreLocation

class ChangeHandlerTestCase: XCTestCase {
    
    var osmDataProviderMock: OSMDataProviderMock!
    var changeHandler: OSMChangeHandling!
    
    override func setUp() {
        super.setUp()
        
        osmDataProviderMock = OSMDataProviderMock()
        changeHandler = InMemoryChangeHandler(osmDataProvider: osmDataProviderMock)
    }
    
    func testNewlyAddedNodesShouldBeStagedAutomatically() {
        let node = makeNode()
        
        changeHandler.add(node)
        
        XCTAssertTrue(changeHandler.stagedNodeIds.contains(node.id))
    }
    
    func testAddNodeShouldNotStageNodesThatAreAlreadyRegisteredAsUpdated() {
        let node = makeNode()
        
        changeHandler.add(node)
        
        // Manually unstage the Node.
        changeHandler.unstage(nodeId: node.id)
        
        // Add the Node once again.
        changeHandler.add(node)
        
        XCTAssertFalse(changeHandler.stagedNodeIds.contains(node.id))
    }
    
    func testAddNodeShouldPostNotificationWhenNodeWasAddedForTheFirstTime() {
        let node = makeNode()
        
        let notificationExpectation = expectation(forNotification: .ChangeHandlerDidAddUpdatedNode,
                                                  object: nil) { (note) -> Bool in
                                                    guard let nodeFromNotification = note.object as? Node else {
                                                        return false
                                                    }
                                                    
                                                    return nodeFromNotification == node
        }
        
        changeHandler.add(node)
        
        wait(for: [notificationExpectation], timeout: 1.0)
    }
    
    func testAddNodeShouldPostNotificationWhenAnUpdatedNodeWasAdded() {
        let node = makeNode()
        
        changeHandler.add(node)
        
        let updatedNode = makeNode(rawTags: ["key": "value"])
        
        let notificationExpectation = expectation(forNotification: .ChangeHandlerDidAddUpdatedNode,
                                                  object: nil) { (note) -> Bool in
                                                    guard let nodeFromNotification = note.object as? Node else {
                                                        return false
                                                    }
                                                    
                                                    return nodeFromNotification == updatedNode
        }
            
        changeHandler.add(updatedNode)
        
        wait(for: [notificationExpectation], timeout: 1.0)
    }
    
    func testAddNodeShouldNotPostNotificationWhenAnEqualNodeDoesAlreadyExist() {
        let node = makeNode()
        
        changeHandler.add(node)
        
        let notificationExpectation = expectation(forNotification: .ChangeHandlerDidAddUpdatedNode,
                                                  object: nil,
                                                  handler: nil)
        notificationExpectation.isInverted = true
        
        changeHandler.add(node)
        
        wait(for: [notificationExpectation], timeout: 1.0)
    }
    
    func testAddNodeShouldIgnoreNodesThatAreEqualToThoseTheOSMDataProviderDiscovered() {
        let node = makeNode(rawTags: ["some-key": "some-value"])
        
        // The OSM data provider already has the same information.
        osmDataProviderMock.nodes = [node]
        
        let notificationExpectation = expectation(forNotification: .ChangeHandlerDidAddUpdatedNode,
                                                  object: nil,
                                                  handler: nil)
        notificationExpectation.isInverted = true
        
        changeHandler.add(node)
        
        wait(for: [notificationExpectation], timeout: 1.0)
        XCTAssertEqual(changeHandler.changedNodes.count, 0)
    }
    
    // MARK: Helper
    
    private func makeNode(rawTags: [String: String] = [:]) -> Node {
        return Node(id: 1, coordinate: CLLocationCoordinate2DMake(53.553100, 10.006700), rawTags: rawTags, version: 9)
    }
    
}
