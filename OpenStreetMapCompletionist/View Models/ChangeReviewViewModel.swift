//
//  ChangeReviewViewModel.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/15/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

protocol ChangeReviewViewModelDelegate: class {
    
    /// Tells the delegate to update its subviews using the values from the view model.
    func updateViewFromViewModel()
    
    /// Is called when a Node was changed and the corresponding section needs to be updated visually.
    ///
    /// - Parameter node: The Node to update the section for.
    func reloadSection(for node: Node)
    
    func showDetailsForNode(_ node: Node)
    
    /// Asks the delegate to perform the OAuth login flow that lets the user authenticate against the OpenStreetMap API.
    ///
    /// - Parameter completion: Closure that should be called when the login flow finished.
    func performOAuthLoginFlow(completion: @escaping (Error?) -> Void)
    
}

class ChangeReviewViewModel: NSObject {
    
    let changeHandler: OSMChangeHandling
    let nodeDataProvider: OSMDataProviding
    let oauthHandler: OAuthHandling
    
    weak var delegate: ChangeReviewViewModelDelegate?
    
    init(changeHandler: OSMChangeHandling, nodeDataProvider: OSMDataProviding, oauthHandler: OAuthHandling) {
        self.changeHandler = changeHandler
        self.nodeDataProvider = nodeDataProvider
        self.oauthHandler = oauthHandler
        
        super.init()
        
        NotificationCenter.default.addObserver(forName: .ChangeHandlerDidAddUpdatedNode,
                                               object: nil,
                                               queue: nil) { [weak self] (notification) in
                                                guard let node = notification.object as? Node else { return }
                                                
                                                self?.delegate?.reloadSection(for: node)
        }
    }
    
    var isUploadButtonEnabled: Bool {
        return 0 < changeHandler.stagedNodeIds.count
    }
    
    var isExplanatorySectionVisible: Bool {
        return 0 == changeHandler.changedNodes.count
    }
    
    func stageNode(id: Int) {
        changeHandler.stage(nodeId: id)
        
        delegate?.updateViewFromViewModel()
    }
    
    func unstageNode(id: Int) {
        changeHandler.unstage(nodeId: id)
        
        delegate?.updateViewFromViewModel()
    }
    
    func isNodeStaged(id: Int) -> Bool {
        return changeHandler.stagedNodeIds.contains(id)
    }
    
    func presentDetailsForNode(id: Int) {
        guard let node = changeHandler.get(id: id) else { return }
        
        delegate?.showDetailsForNode(node)
    }
    
    func startUpload(_ completion: @escaping (Error?) -> Void) {
        if !oauthHandler.isAuthorized {
            delegate?.performOAuthLoginFlow(completion: { (error) in
                if let error = error {
                    completion(error)
                } else {
                    completion(nil)
                }
            })
        }
    }

}
