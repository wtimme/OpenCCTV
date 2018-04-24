//
//  AlamofireHTTPRequestHandler.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/24/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Alamofire

class AlamofireHTTPRequestHandler: NSObject, HTTPRequestHandling {
    
    // MARK: HTTPRequestHandling
    
    func request(_ url: URL, _ parameters: [String: Any]? = nil, _ completion: @escaping (DataResponse) -> Void) {
        Alamofire.request(url).response { response in
            completion(DataResponse(data: response.data,
                                    error: response.error))
        }
    }

}
