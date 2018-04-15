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
    var viewModel: ChangeReviewViewModel!
    
    override func setUp() {
        super.setUp()
        
        changeHandlerMock = ChangeHandlerMock()
        viewModel = ChangeReviewViewModel(changeHandler: changeHandlerMock)
    }
    
    func testUploadButtonShouldBeDisabledWhenThereAreNoChangedNodes() {
        XCTAssertFalse(viewModel.isUploadButtonEnabled)
    }
    
    func testUploadButtonShouldBeEnabledWhenThereAreChangedNodes() {
        let node = Node(id: 1, coordinate: CLLocationCoordinate2DMake(53.553100, 10.006700), rawTags: [:])
        changeHandlerMock.changedNodes[1] = node
        
        XCTAssertTrue(viewModel.isUploadButtonEnabled)
    }
    
}
