//
//  APIClientMock.swift
//  OpenStreetMapCompletionistTests
//
//  Created by Wolfgang Timme on 4/24/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

@testable import OpenStreetMapCompletionist

class APIClientMock: NSObject, APIClientProtocol {
    
    var nodeDownloadNodeId: Int?
    var nodeDownloadResult: Node?
    var nodeDownloadError: Error?
    
    func downloadNode(id: Int, _ completion: @escaping (Node?, Error?) -> Void) {
        nodeDownloadNodeId = id
        
        completion(nodeDownloadResult, nodeDownloadError)
    }

}
