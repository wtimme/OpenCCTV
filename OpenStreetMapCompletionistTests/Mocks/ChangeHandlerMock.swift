//
//  ChangeHandlerMock.swift
//  OpenStreetMapCompletionistTests
//
//  Created by Wolfgang Timme on 4/15/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

@testable import OpenStreetMapCompletionist

class ChangeHandlerMock: NSObject, OSMChangeHandling {
    
    func add(_ node: Node) {
        changedNodes[node.id] = node
    }
    
    var changedNodes = [Int : Node]()
    
    func get(id: Int) -> Node? {
        return changedNodes[id]
    }
    
    // MARK: Staging
    
    var stagedNodeIds = Set<Int>()
    
    func stage(nodeId: Int) {
        stagedNodeIds.insert(nodeId)
    }
    
    func unstage(nodeId: Int) {
        stagedNodeIds.remove(nodeId)
    }
    
    // MARK: Reverting changes
    
    func revertAllChanges() {
        changedNodes.removeAll()
        stagedNodeIds.removeAll()
    }

}
