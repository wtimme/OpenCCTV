//
//  HTTPRequestHandling.swift
//  OSMSwift
//
//  Created by Wolfgang Timme on 6/26/18.
//

import Foundation

public struct DataResponse {
    let data: Data?
    let error: Error?
    
    public init(data: Data? = nil, error: Error? = nil) {
        self.data = data
        self.error = error
    }
}

public protocol HTTPRequestHandling {
    
    func request(_ baseURL: URL,
                 _ path: String,
                 _ parameters: [String: Any]?,
                 _ completion: @escaping (DataResponse) -> Void)
    
}

extension HTTPRequestHandling {
    func request(_ baseURL: URL, path: String? = nil, _ completion: @escaping (DataResponse) -> Void) {
        request(baseURL,
                path ?? "",
                nil,
                completion)
    }
}
