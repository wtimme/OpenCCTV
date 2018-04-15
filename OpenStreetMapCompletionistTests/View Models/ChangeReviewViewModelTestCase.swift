//
//  ChangeReviewViewModelTestCase.swift
//  OpenStreetMapCompletionistTests
//
//  Created by Wolfgang Timme on 4/15/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import XCTest

@testable import OpenStreetMapCompletionist
import CoreLocation

class ChangeReviewViewModelTestCase: XCTestCase {
    
    var changeHandlerMock: ChangeHandlerMock!
    var nodeDataProviderMock: OSMDataProviderMock!
    var viewModel: ChangeReviewViewModel!
    
    var delegateMock: ChangeReviewViewModelDelegateMock!
    
    override func setUp() {
        super.setUp()
        
        changeHandlerMock = ChangeHandlerMock()
        nodeDataProviderMock = OSMDataProviderMock()
        viewModel = ChangeReviewViewModel(changeHandler: changeHandlerMock,
                                          nodeDataProvider: nodeDataProviderMock)
        
        delegateMock = ChangeReviewViewModelDelegateMock()
        viewModel.delegate = delegateMock
    }
    
    func testUploadButtonShouldBeDisabledWhenThereAreNoChangedNodes() {
        XCTAssertFalse(viewModel.isUploadButtonEnabled)
    }
    
    func testUploadButtonShouldBeEnabledWhenThereAreChangedNodes() {
        changeHandlerMock.changedNodes[1] = makeNode()
        
        XCTAssertTrue(viewModel.isUploadButtonEnabled)
    }
    
    func testExplanatorySectionIsVisibleWhenThereAreNoChangedNodes() {
        XCTAssertTrue(viewModel.isExplanatorySectionVisible)
    }
    
    func testExplanatorySectionIsNotVisibleWhenThereAreChangedNodes() {
        changeHandlerMock.changedNodes[1] = makeNode()
        
        XCTAssertFalse(viewModel.isExplanatorySectionVisible)
    }
    
    func testDelegateShouldNotBeAskedToShowDetailsForNodeThatDoesNotExist() {
        viewModel.presentDetailsForNode(id: 404)
        
        XCTAssertNil(delegateMock.nodeToPresent)
    }
    
    func testDelegateShouldHaveBeenAskedToShowDetailsForNodeThatExists() {
        let node = makeNode()
        
        changeHandlerMock.changedNodes[1] = node
        viewModel.presentDetailsForNode(id: 1)
        
        XCTAssertEqual(delegateMock.nodeToPresent, node)
    }
    
    // MARK: Helper
    
    private func makeNode() -> Node {
        return Node(id: 1, coordinate: CLLocationCoordinate2DMake(53.553100, 10.006700), rawTags: [:])
    }
    
}
