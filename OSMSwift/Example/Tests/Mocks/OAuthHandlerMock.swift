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
    
    var startOAuthFlowFromViewController: UIViewController?
    var startOAuthFlowCredentials: OAuthCredentials?
    var startOAuthFlowCredentialsError: Error?
    
    // MARK: OAuthHandling
    
    func startOAuthFlow(from viewController: UIViewController, _ completion: @escaping (OAuthCredentials?, Error?) -> Void) {
        startOAuthFlowFromViewController = viewController
        
        completion(startOAuthFlowCredentials, startOAuthFlowCredentialsError)
    }
    
    
}
