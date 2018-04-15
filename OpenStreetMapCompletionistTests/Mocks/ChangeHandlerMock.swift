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

}
