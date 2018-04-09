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
    enum Environment {
        /// master.apis.dev.openstreetmap.org
        case development

        /// www.openstreetmap.org
        case live
    }

    private let oauthSwift: OAuth1Swift
    private let keychainHandler: KeychainHandling

    init(consumerKey: String,
         consumerSecret: String,
         requestTokenURLString: String,
         authorizeURLString: String,
         accessTokenURLString: String,
         keychainHandler: KeychainHandling) {
        oauthSwift = OAuth1Swift(consumerKey: consumerKey,
                                 consumerSecret: consumerSecret,
                                 requestTokenUrl: requestTokenURLString,
                                 authorizeUrl: authorizeURLString,
                                 accessTokenUrl: accessTokenURLString)

        self.keychainHandler = keychainHandler
    }

    convenience init(environment: Environment,
                     consumerKey: String,
                     consumerSecret: String,
                     keychainHandler: KeychainHandling) {
        let requestTokenURLString: String
        let authorizeURLString: String
        let accessTokenURLString: String
        switch environment {
        case .development:
            requestTokenURLString = "https://master.apis.dev.openstreetmap.org/oauth/request_token"
            authorizeURLString = "https://master.apis.dev.openstreetmap.org/oauth/authorize"
            accessTokenURLString = "https://master.apis.dev.openstreetmap.org/oauth/access_token"
            break
        case .live:
            requestTokenURLString = "https://master.apis.dev.openstreetmap.org/oauth/request_token"
            authorizeURLString = "https://master.apis.dev.openstreetmap.org/oauth/authorize"
            accessTokenURLString = "https://master.apis.dev.openstreetmap.org/oauth/access_token"
            break
        }

        self.init(consumerKey: consumerKey,
                  consumerSecret: consumerSecret,
                  requestTokenURLString: requestTokenURLString,
                  authorizeURLString: authorizeURLString,
                  accessTokenURLString: accessTokenURLString,
                  keychainHandler: keychainHandler)
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
