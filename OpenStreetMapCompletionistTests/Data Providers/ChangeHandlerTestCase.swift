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
    
    var changeHandler: OSMChangeHandling!
    
    override func setUp() {
        super.setUp()
        
        changeHandler = InMemoryChangeHandler()
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
        
        let notificationObserverMock = NotificationCenterObserverMock(notificationName: .ChangeHandlerDidAddUpdatedNode)
        
        changeHandler.add(node)
        
        XCTAssertTrue(notificationObserverMock.didReceiveNotification)
        
        guard let nodeFromNotification = notificationObserverMock.object as? Node else {
            XCTFail("The notification should contain a `Node`.")
            return
        }
        
        XCTAssertEqual(nodeFromNotification, node)
    }
    
    func testAddNodeShouldPostNotificationWhenAnUpdatedNodeWasAdded() {
        let node = makeNode()
        
        changeHandler.add(node)
        
        let updatedNode = makeNode(rawTags: ["key": "value"])
            
        let notificationObserverMock = NotificationCenterObserverMock(notificationName: .ChangeHandlerDidAddUpdatedNode)
        
        changeHandler.add(updatedNode)
        
        XCTAssertTrue(notificationObserverMock.didReceiveNotification)
        
        guard let nodeFromNotification = notificationObserverMock.object as? Node else {
            XCTFail("The notification should contain a `Node`.")
            return
        }
        
        XCTAssertEqual(nodeFromNotification, updatedNode)
    }
    
    func testAddNodeShouldNotPostNotificationWhenAnEqualNodeDoesAlreadyExist() {
        let node = makeNode()
        
        changeHandler.add(node)
        
        let notificationObserverMock = NotificationCenterObserverMock(notificationName: .ChangeHandlerDidAddUpdatedNode)
        
        changeHandler.add(node)
        
        XCTAssertFalse(notificationObserverMock.didReceiveNotification)
    }
    
    // MARK: Helper
    
    class NotificationCenterObserverMock: NSObject {
        public private(set) var didReceiveNotification = false
        public private(set) var object: Any?
        
        init(notificationName: Notification.Name) {
            super.init()
            
            NotificationCenter.default.addObserver(forName: notificationName,
                                                   object: nil,
                                                   queue: nil) { [weak self] (notification) in
                                                    self?.didReceiveNotification = true
                                                    self?.object = notification.object
            }
        }
    }
    
    private func makeNode(rawTags: [String: String] = [:]) -> Node {
        return Node(id: 1, coordinate: CLLocationCoordinate2DMake(53.553100, 10.006700), rawTags: rawTags, version: 9)
    }
    
}
