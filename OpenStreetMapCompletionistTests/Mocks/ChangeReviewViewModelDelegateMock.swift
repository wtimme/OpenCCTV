//
//  ChangeReviewViewModelDelegateMock.swift
//  OpenStreetMapCompletionistTests
//
//  Created by Wolfgang Timme on 4/15/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

@testable import OpenStreetMapCompletionist

class ChangeReviewViewModelDelegateMock: NSObject, ChangeReviewViewModelDelegate {
    
    /// The `Node` that the delegate was asked to present.
    var nodeToPresent: Node?
    
    /// The `Node` that the delegate was asked to reload the section for.
    var nodeToReloadSectionFor: Node?
    
    public private(set) var wasAskedToUpdateView = false
    
    func updateViewFromViewModel() {
        wasAskedToUpdateView = true
    }
    
    func reloadSection(for node: Node) {
        nodeToReloadSectionFor = node
    }

    func showDetailsForNode(_ node: Node) {
        nodeToPresent = node
    }
    
}
