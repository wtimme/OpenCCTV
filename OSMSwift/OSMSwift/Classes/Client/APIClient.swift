//
//  APIClient.swift
//  OSMSwift
//
//  Created by Wolfgang Timme on 6/24/18.
//

import Foundation

public protocol APIClientProtocol {
    
    func addAccountUsingOAuth(from presentingViewController: UIViewController,
                              _ completion: @escaping (Error?) -> Void)
    
}

public class APIClient: APIClientProtocol {
    
    public struct OAuthConfiguration {
        /// Setup a URL scheme in your app's Info.plist.
        let callbackURLScheme: String
        
        let consumerKey: String
        let consumerSecret: String
        
        /// After OAuth completed, this will redirect users back to the app using this URL.
        var callbackURLString: String {
            return "\(callbackURLScheme)://oauth-callback/osm"
        }
    }
    
    // MARK: Private
    
    private let baseURL: URL
    private let oauthHandler: OAuthHandling
    
    // MARK: Public
    
    public init(baseURL: URL, oauthHandler: OAuthHandling) {
        self.baseURL = baseURL
        self.oauthHandler = oauthHandler
    }
    
    // MARK: APIClientProtocol
    
    public func addAccountUsingOAuth(from presentingViewController: UIViewController,
                                     _ completion: @escaping (Error?) -> Void) {
        oauthHandler.startOAuthFlow(from: presentingViewController) { (_, error) in
            guard error == nil else {
                completion(error)
                return
            }
        }
    }
    
    public func loginUsingOAuth(from presentingViewController: UIViewController, _ completion: @escaping (Error?) -> Void) {
        oauthHandler.startOAuthFlow(from: presentingViewController) { (credentials, error) in
            // TODO: Implement me
        }
    }
    
}
