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
    
    var didCallPerformOAuthLoginFlow = false
    
    /// The error that is returned when the login flow is performed.
    var oauthLoginFlowError: Error?
    
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
    
    func performOAuthLoginFlow(completion: @escaping (Error?) -> Void) {
        didCallPerformOAuthLoginFlow = true
        
        completion(oauthLoginFlowError)
    }
    
    func askForConfirmationBeforeRevertingChanges(_ completion: @escaping (Bool) -> Void) { }
    
    func dismiss() { }
    
}
