//
//  OAuthHandler.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/9/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

import OAuthSwift

protocol OAuthHandling {
    func authorize(from viewController: UIViewController, _ completion: @escaping (Error?) -> Void)
    var isAuthorized: Bool { get }
    func removeCredentials()
}

class OAuthHandler: NSObject, OAuthHandling {
    private let oauthSwift: OAuth1Swift
    private let keychainHandler: KeychainHandling

    init(environment: Environment,
         keychainHandler: KeychainHandling) {
        oauthSwift = OAuth1Swift(consumerKey: environment.oauthConsumerKey,
                                 consumerSecret: environment.oauthConsumerSecret,
                                 requestTokenUrl: environment.oauthBaseURL.appendingPathComponent("oauth/request_token").absoluteString,
                                 authorizeUrl: environment.oauthBaseURL.appendingPathComponent("oauth/authorize").absoluteString,
                                 accessTokenUrl: environment.oauthBaseURL.appendingPathComponent("oauth/access_token").absoluteString)

        self.keychainHandler = keychainHandler
    }

    // MARK: OAuthHandling

    func authorize(from viewController: UIViewController, _ completion: @escaping (Error?) -> Void) {
        guard !isAuthorized else {
            // There's no need to authorize; stop here.
            completion(nil)
            return
        }

        // Use an in-app Safari web view controller instead of redirecting to an external app.
        oauthSwift.authorizeURLHandler = SafariURLHandler(viewController: viewController, oauthSwift: oauthSwift)

        _ = oauthSwift.authorize(withCallbackURL: "osm-completionist://oauth-callback/osm", success: { [weak self] credential, _, _ in
            self?.keychainHandler.set(key: .oauthToken, value: credential.oauthToken)
            self?.keychainHandler.set(key: .oauthTokenSecret, value: credential.oauthTokenSecret)

            completion(nil)
        }, failure: completion)
    }

    var isAuthorized: Bool {
        return nil != keychainHandler.get(.oauthToken) && nil != keychainHandler.get(.oauthTokenSecret)
    }

    func removeCredentials() {
        keychainHandler.removeValue(for: .oauthToken)
        keychainHandler.removeValue(for: .oauthTokenSecret)
    }
}
