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
    
    func revertAllChanges()
}

extension Notification.Name {
    public static let ChangeHandlerDidAddUpdatedNode = NSNotification.Name("ChangeHandlerDidAddUpdatedNode")
}

class InMemoryChangeHandler: NSObject, OSMChangeHandling {
    
    // Public
    
    public private(set) var changedNodes = [Int: Node]()
    
    init(osmDataProvider: OSMDataProviding) {
        self.osmDataProvider = osmDataProvider
    }
    
    // Private
    
    private let osmDataProvider: OSMDataProviding
    
    // MARK: OSMChangeHandling
    
    func add(_ node: Node) {
        guard node != osmDataProvider.node(id: node.id) else {
            // This information matches the one on the server; ignore.
            return
        }
        
        let existingNode = get(id: node.id)
        
        changedNodes[node.id] = node
        
        if nil == existingNode || node != existingNode {
            NotificationCenter.default.post(name: .ChangeHandlerDidAddUpdatedNode, object: node)
        }
        
        if nil == existingNode {
            // Automatically stage nodes that were just modified for the first time.
            stage(nodeId: node.id)
        }
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
    
    // MARK: OSMChangeHandling - Reverting
    
    func revertAllChanges() {
        changedNodes.removeAll()
        stagedNodeIds.removeAll()
    }

}
