//
//  OAuthHandlerMock.swift
//  OpenStreetMapCompletionistTests
//
//  Created by Wolfgang Timme on 4/20/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import UIKit

@testable import OpenStreetMapCompletionist

class OAuthHandlerMock: NSObject, OAuthHandling {
    
    var authorizeViewController: UIViewController?
    var authorizationError: Error?
    
    func authorize(from viewController: UIViewController, _ completion: @escaping (Error?) -> Void) {
        authorizeViewController = viewController
        completion(authorizationError)
    }
    
    var isAuthorized: Bool = false
    
    func removeCredentials() { }
    

}
