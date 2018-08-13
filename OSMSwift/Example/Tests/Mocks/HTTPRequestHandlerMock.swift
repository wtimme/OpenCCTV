//
//  HTTPRequestHandlerMock.swift
//  OSMSwift_Tests
//
//  Created by Wolfgang Timme on 6/26/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

@testable import OSMSwift

class HTTPRequestHandlerMock: HTTPRequestHandling {
    /// The parameters with which `request(_:_:_:_:)` was called.
    var baseURL: URL?
    var path: String?
    var parameters: [String: Any]?
    
    /// Use this variable to mock the response from the server.
    var dataResponse = DataResponse(data: nil, error: nil)
    
    func request(_ baseURL: URL,
                 _ path: String,
                 _ parameters: [String : Any]?,
                 _ completion: @escaping (DataResponse) -> Void) {
        self.baseURL = baseURL
        self.path = path
        self.parameters = parameters
        
        completion(dataResponse)
    }

}
