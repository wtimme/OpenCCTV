//
//  HTTPRequestHandling.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/24/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

struct DataResponse {
    let data: Data?
    let error: Error?
}

protocol HTTPRequestHandling {
    
    func request(_ url: URL, _ parameters: [String: Any]?, _ completion: @escaping (DataResponse) -> Void)
    
}

extension HTTPRequestHandling {
    func request(_ url: URL, _ completion: @escaping (DataResponse) -> Void) {
        request(url, nil, completion)
    }
}
