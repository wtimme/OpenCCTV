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
    
    // MARK: Helper
    
    private func makeNode() -> Node {
        return Node(id: 1, coordinate: CLLocationCoordinate2DMake(53.553100, 10.006700), rawTags: [:])
    }
    
}
