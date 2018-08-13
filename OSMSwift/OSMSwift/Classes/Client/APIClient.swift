//
//  APIClient.swift
//  OSMSwift
//
//  Created by Wolfgang Timme on 6/24/18.
//

import Foundation

import SwiftOverpass

public enum APIClientError: Error {
    case notAuthenticated
}

enum Endpoint: String {
    case getPermissions = "/api/0.6/permissions"
}

public protocol APIClientProtocol {
    
    var isAuthenticated: Bool { get }
    
    func logout()
    
    func addAccountUsingOAuth(from presentingViewController: UIViewController,
                              _ completion: @escaping (Error?) -> Void)
    
    /// Request the list with permissions from the server.
    ///
    /// - Parameter completion: Closure that is executed once the permissions were determined or an error occured.
    func permissions(_ completion: @escaping ([Permission], Error?) -> Void)
    
    /// Attempts to download the map data inside the given bounding box.
    ///
    /// - Parameters:
    ///   - boundingBox: The bounding box that confines the map data.
    ///   - completion: Closure that is executed once the map data was downloaded completely or an error occured.
    func mapData(inside boundingBox: BoundingBox, _ completion: @escaping ([OverpassElement], Error?) -> Void)
    
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
    private let keychainHandler: KeychainHandling
    private let oauthHandler: OAuthHandling
    private let httpRequestHandler: HTTPRequestHandling
    
    // MARK: Public
    
    public init(baseURL: URL,
                keychainHandler: KeychainHandling,
                oauthHandler: OAuthHandling,
                httpRequestHandler: HTTPRequestHandling) {
        self.baseURL = baseURL
        self.keychainHandler = keychainHandler
        self.oauthHandler = oauthHandler
        self.httpRequestHandler = httpRequestHandler
        
        if let credentials = keychainHandler.oauthCredentials {
            oauthHandler.setupClientCredentials(credentials)
        }
    }
    
    // MARK: APIClientProtocol
    
    public var isAuthenticated: Bool {
        return nil != keychainHandler.oauthCredentials
    }
    
    public func logout() {
        keychainHandler.setCredentials(nil)
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
            
            self?.keychainHandler.setCredentials(credentials) 
            
            completion(nil)
        }
    }
    
    public func permissions(_ completion: @escaping ([Permission], Error?) -> Void) {
        guard isAuthenticated else {
            completion([], APIClientError.notAuthenticated)
            return
        }
        
        httpRequestHandler.request(baseURL, path: "/api/0.6/permissions") { (response) in
            guard response.error == nil else {
                completion([], response.error)
                return
            }
            
            guard let responseData = response.data else {
                completion([], nil)
                return
            }
            
            completion(Permission.parseListOfPermissions(from: responseData),
                       nil)
        }
    }
    
    public func mapData(inside boundingBox: BoundingBox, _ completion: @escaping ([OverpassElement], Error?) -> Void) {
        let path = "/api/0.6/map?bbox=\(boundingBox.queryString)"
        
        httpRequestHandler.request(baseURL, path: path) { (response) in
            guard response.error == nil else {
                completion([], response.error)
                return
            }
            
            guard let responseData = response.data else {
                completion([], nil)
                return
            }
            
            completion([], nil)
        }
    }
    
}
