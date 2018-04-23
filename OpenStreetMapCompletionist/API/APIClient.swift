//
//  APIClient.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/23/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

import Alamofire
import AEXML

protocol APIClientProtocol {
    
    func downloadNode(id: Int, _ completion: @escaping (Node?, Error?) -> Void)
    
}

class APIClient: NSObject, APIClientProtocol {
    
    init(baseURL: URL, oauthHandler: OAuthHandling) {
        self.baseURL = baseURL
        self.oauthHandler = oauthHandler
    }
    
    // MARK: Private
    
    private let baseURL: URL
    private let oauthHandler: OAuthHandling
    
    // MARK: APIClientProtocol
    
    func downloadNode(id: Int, _ completion: @escaping (Node?, Error?) -> Void) {
        let url = baseURL.appendingPathComponent("/api/0.6/node/\(id)")
        
        Alamofire.request(url).response { response in
            if let error = response.error {
                completion(nil, error)
                return
            } else if let data = response.data {
                let node = Node(xml: data)
                
                completion(node, nil)
            }
        }
    }

}
