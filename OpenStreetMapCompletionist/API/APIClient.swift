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

/// An area on the map.
///
/// It can be used to query the OpenStreetMap API:
/// https://wiki.openstreetmap.org/wiki/API_v0.6#Retrieving_map_data_by_bounding_box:_GET_.2Fapi.2F0.6.2Fmap
struct BoundingBox {
    let left: Double
    let bottom: Double
    let right: Double
    let top: Double
}

protocol APIClientProtocol {
    
    func downloadNode(id: Int, _ completion: @escaping (Node?, Error?) -> Void)
    
}

class APIClient: NSObject, APIClientProtocol {
    
    init(baseURL: URL,
         oauthHandler: OAuthHandling,
         requestHandler: HTTPRequestHandling = AlamofireHTTPRequestHandler()) {
        self.baseURL = baseURL
        self.oauthHandler = oauthHandler
        self.requestHandler = requestHandler
    }
    
    // MARK: Private
    
    private let baseURL: URL
    private let oauthHandler: OAuthHandling
    private let requestHandler: HTTPRequestHandling
    
    // MARK: APIClientProtocol
    
    func downloadNode(id: Int, _ completion: @escaping (Node?, Error?) -> Void) {
        let url = baseURL.appendingPathComponent("api/0.6/node/\(id)")
        
        requestHandler.request(url) { response in
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
