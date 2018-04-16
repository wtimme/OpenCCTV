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
    
}

class ChangeReviewViewModel: NSObject {
    
    let changeHandler: OSMChangeHandling
    let nodeDataProvider: OSMDataProviding
    
    weak var delegate: ChangeReviewViewModelDelegate?
    
    init(changeHandler: OSMChangeHandling, nodeDataProvider: OSMDataProviding) {
        self.changeHandler = changeHandler
        self.nodeDataProvider = nodeDataProvider
        
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

}
