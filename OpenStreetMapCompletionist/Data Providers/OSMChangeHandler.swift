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
}

class InMemoryChangeHandler: NSObject, OSMChangeHandling {
    
    public private(set) var changedNodes = [Int: Node]()
    
    // MARK: OSMChangeHandling
    
    func add(_ node: Node) {
        changedNodes[node.id] = node
    }
    
    func get(id: Int) -> Node? {
        return changedNodes[id]
    }

}
