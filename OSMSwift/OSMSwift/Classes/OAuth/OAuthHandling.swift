//
//  OAuthHandling.swift
//  OSMSwift
//
//  Created by Wolfgang Timme on 6/25/18.
//

import Foundation
import UIKit

public struct OAuthCredentials: Equatable {
    let token: String
    let secret: String
    
    public init(token: String, secret: String) {
        self.token = token
        self.secret = secret
    }
}

public protocol OAuthHandling {
    
    func setupClientCredentials(_ credentials: OAuthCredentials)
    
    /// Starts the OAuth flow for obtaining `OAuthCredentials`.
    ///
    /// - Parameters:
    ///   - viewController: The view controller from which to start the flow.
    ///   - completion: Closure that is being called when the credentials were retrieved or an error occured.
    func startOAuthFlow(from viewController: UIViewController,
                        _ completion: @escaping (OAuthCredentials?, Error?) -> Void)
}
