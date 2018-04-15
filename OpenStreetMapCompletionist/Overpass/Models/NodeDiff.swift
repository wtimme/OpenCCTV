//
//  NodeDiff.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/15/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

class NodeDiff: NSObject {
    let nodeId: Int
    let addedTags: [String: String]
    let updatedTags: [String: String]
    let removedTags: [String: String]
    
    init(nodeId: Int, addedTags: [String: String], updatedTags: [String: String], removedTags: [String: String]) {
        self.nodeId = nodeId
        self.addedTags = addedTags
        self.updatedTags = updatedTags
        self.removedTags = removedTags
    }
    
    convenience init(node: Node, originalNode: Node?) {
        var addedTags = [String: String]()
        var updatedTags = [String: String]()
        var removedTags = [String: String]()
        
        if let originalNode = originalNode {
            addedTags = node.rawTags.filter({ (key, value) -> Bool in
                return nil == originalNode.rawTags[key]
            })
            
            updatedTags = node.rawTags.filter({ (key, value) -> Bool in
                guard let originalValue = originalNode.rawTags[key] else { return false }
                
                return originalValue != value
            })
            
            removedTags = originalNode.rawTags.filter({ (key, value) -> Bool in
                return nil == node.rawTags[key]
            })
        } else {
            // All tags are new.
            addedTags = node.rawTags
        }
        
        self.init(nodeId: node.id, addedTags: addedTags, updatedTags: updatedTags, removedTags: removedTags)
    }
}
