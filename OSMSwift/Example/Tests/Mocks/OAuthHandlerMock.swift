//
//  OAuthHandlerMock.swift
//  OSMSwift_Tests
//
//  Created by Wolfgang Timme on 6/25/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import OSMSwift

@testable import OSMSwift

class OAuthHandlerMock: NSObject, OAuthHandling {
    
    var authorizeViewController: UIViewController?
    var authorizationError: Error?
    
    // MARK: OAuthHandling
    
    func startOAuthFlow(from viewController: UIViewController, _ completion: @escaping (OAuthCredentials?, Error?) -> Void) {
        authorizeViewController = viewController
        
        completion(nil, authorizationError)
    }
    
    
}
