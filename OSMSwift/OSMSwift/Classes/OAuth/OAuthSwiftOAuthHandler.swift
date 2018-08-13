//
//  OAuthSwiftOAuthHandler.swift
//  OSMSwift
//
//  Created by Wolfgang Timme on 6/26/18.
//

import OAuthSwift
import Alamofire
import OAuthSwiftAlamofire

public class OAuthSwiftOAuthHandler: OAuthHandling {
    
    public init(baseURL: URL,
                consumerKey: String,
                consumerSecret: String) {
        oauthSwift = OAuth1Swift(consumerKey: consumerKey,
                                 consumerSecret: consumerSecret,
                                 requestTokenUrl: baseURL.appendingPathComponent("oauth/request_token").absoluteString,
                                 authorizeUrl: baseURL.appendingPathComponent("oauth/authorize").absoluteString,
                                 accessTokenUrl: baseURL.appendingPathComponent("oauth/access_token").absoluteString)
        
        configureAlamofireToSignRequests(using: oauthSwift)
    }
    
    // MARK: Private
    
    private let oauthSwift: OAuth1Swift
    
    private func configureAlamofireToSignRequests(using oauthSwit: OAuthSwift) {
        SessionManager.default.adapter = oauthSwift.requestAdapter
    }
    
    // MARK: OAuthHandling
    
    public func setupClientCredentials(_ credentials: OAuthCredentials) {
        oauthSwift.client = OAuthSwiftClient(consumerKey: oauthSwift.client.credential.consumerKey,
                                             consumerSecret: oauthSwift.client.credential.consumerSecret,
                                             oauthToken: credentials.token,
                                             oauthTokenSecret: credentials.secret,
                                             version: .oauth1)
    }
    
    public func startOAuthFlow(from viewController: UIViewController, _ completion: @escaping (OAuthCredentials?, Error?) -> Void) {
        // Use an in-app Safari web view controller instead of redirecting to an external app.
        oauthSwift.authorizeURLHandler = SafariURLHandler(viewController: viewController,
                                                          oauthSwift: oauthSwift)
        
        _ = oauthSwift.authorize(withCallbackURL: "osm-completionist://oauth-callback/osm", success: { (credentials, _, _) in
            let oauthCredentials = OAuthCredentials(token: credentials.oauthToken,
                                                    secret: credentials.oauthTokenSecret)
            
            completion(oauthCredentials, nil)
        }, failure: { (error) in
            completion(nil, error)
        })
    }

}
