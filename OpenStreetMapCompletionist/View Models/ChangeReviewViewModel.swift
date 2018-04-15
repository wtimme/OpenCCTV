//
//  ChangeReviewViewModel.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/15/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

protocol ChangeReviewViewModelDelegate: class {
    func showDetailsForNode(_ node: Node)
}

class ChangeReviewViewModel: NSObject {
    
    let changeHandler: OSMChangeHandling
    let nodeDataProvider: OSMDataProviding
    
    weak var delegate: ChangeReviewViewModelDelegate?
    
    init(changeHandler: OSMChangeHandling, nodeDataProvider: OSMDataProviding) {
        self.changeHandler = changeHandler
        self.nodeDataProvider = nodeDataProvider
    }
    
    var isUploadButtonEnabled: Bool {
        return 0 < changeHandler.changedNodes.count
    }
    
    var isExplanatorySectionVisible: Bool {
        return 0 == changeHandler.changedNodes.count
    }
    
    func presentDetailsForNode(id: Int) {
        guard let node = changeHandler.get(id: id) else { return }
        
        delegate?.showDetailsForNode(node)
    }

}
