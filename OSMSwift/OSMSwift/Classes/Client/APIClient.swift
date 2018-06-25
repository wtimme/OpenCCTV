//
//  APIClient.swift
//  OSMSwift
//
//  Created by Wolfgang Timme on 6/24/18.
//

import Foundation

public protocol APIClientProtocol {
    
    var isAuthenticated: Bool { get }
    
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
    private var keychainHandler: KeychainHandling
    private let oauthHandler: OAuthHandling
    
    // MARK: Public
    
    public init(baseURL: URL, keychainHandler: KeychainHandling, oauthHandler: OAuthHandling) {
        self.baseURL = baseURL
        self.keychainHandler = keychainHandler
        self.oauthHandler = oauthHandler
    }
    
    // MARK: APIClientProtocol
    
    public var isAuthenticated: Bool {
        return nil != keychainHandler.oauthCredentials
    }
    
    public func addAccountUsingOAuth(from presentingViewController: UIViewController,
                                     _ completion: @escaping (Error?) -> Void) {
        oauthHandler.startOAuthFlow(from: presentingViewController) { [weak self] (credentials, error) in
            guard error == nil else {
                completion(error)
                return
            }
            
            guard let credentials = credentials else {
                assertionFailure("There should be either credentials or an error.")
                return
            }
            
            self?.keychainHandler.oauthCredentials = credentials
            
            completion(nil)
        }
    }
    
}
