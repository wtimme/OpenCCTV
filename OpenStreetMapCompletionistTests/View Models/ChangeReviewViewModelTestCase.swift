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
    
    func testUploadButtonShouldBeDisabledWhenThereAreNoStagedNodes() {
        XCTAssertFalse(viewModel.isUploadButtonEnabled)
    }
    
    func testUploadButtonShouldBeEnabledWhenThereAreStagedNodes() {
        changeHandlerMock.stagedNodeIds.insert(1)
        
        XCTAssertTrue(viewModel.isUploadButtonEnabled)
    }
    
    func testDelegateShouldHaveBeenAskedToUpdateViewAfterStaging() {
        viewModel.stageNode(id: 1)
        
        XCTAssertTrue(delegateMock.wasAskedToUpdateView)
    }
    
    func testDelegateShouldHaveBeenAskedToUpdateViewAfterUnstaging() {
        viewModel.unstageNode(id: 1)
        
        XCTAssertTrue(delegateMock.wasAskedToUpdateView)
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
    
    func testIsNodeStagedShouldAskChangeHandler() {
        XCTAssertFalse(viewModel.isNodeStaged(id: 1))
        
        changeHandlerMock.stagedNodeIds.insert(1)
        
        XCTAssertTrue(viewModel.isNodeStaged(id: 1))
    }
    
    func testStageNodeShouldTellChangeHandlerToStageIt() {
        viewModel.stageNode(id: 2)
        
        XCTAssertTrue(changeHandlerMock.stagedNodeIds.contains(2))
    }
    
    func testUnstageNodeShouldTellChangeHandlerToUnstageIt() {
        changeHandlerMock.stagedNodeIds.insert(3)
        
        viewModel.unstageNode(id: 3)
        
        XCTAssertFalse(changeHandlerMock.stagedNodeIds.contains(3))
    }
    
    func testViewModelShouldAskToReloadSectionWhenItReceivedChangeHandlerDidAddUpdatedNodeNotification() {
        let updatedNode = makeNode()
        
        NotificationCenter.default.post(name: .ChangeHandlerDidAddUpdatedNode,
                                        object: updatedNode)
        
        XCTAssertEqual(delegateMock.nodeToReloadSectionFor, updatedNode)
    }
    
    // MARK: Helper
    
    private func makeNode() -> Node {
        return Node(id: 1, coordinate: CLLocationCoordinate2DMake(53.553100, 10.006700), rawTags: [:])
    }
    
}
