//
//  OSMChangeHandler.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/14/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

protocol OSMChangeHandling {
    func add(_ node: Node)
    var changedNodes: [Int: Node] { get }
    func get(id: Int) -> Node?
    
    var stagedNodeIds: Set<Int> { get }
    func stage(nodeId: Int)
    func unstage(nodeId: Int)
}

class InMemoryChangeHandler: NSObject, OSMChangeHandling {
    
    public private(set) var changedNodes = [Int: Node]()
    
    // MARK: OSMChangeHandling
    
    func add(_ node: Node) {
        changedNodes[node.id] = node
        
        // Automatically stage nodes.
        stage(nodeId: node.id)
    }
    
    func get(id: Int) -> Node? {
        return changedNodes[id]
    }
    
    // MARK: OSMChangeHandling - Staging
    
    public private(set) var stagedNodeIds = Set<Int>()
    
    func stage(nodeId: Int) {
        stagedNodeIds.insert(nodeId)
    }
    
    func unstage(nodeId: Int) {
        stagedNodeIds.remove(nodeId)
    }

}
