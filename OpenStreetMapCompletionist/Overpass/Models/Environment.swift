//
//  Environment.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/9/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

struct Environment {
    let apiBaseURL: URL
    
    // OAuth
    let oauthBaseURL: URL
    let oauthConsumerKey: String
    let oauthConsumerSecret: String
}

extension Environment {
    static var current: Environment {
        guard let currentEnvironment = Environment.development else {
            fatalError("Unable to determine the environment. Please make sure that the Info.plist contains a proper OAuth configuration.")
        }
        
        return currentEnvironment
    }
    
    static var development: Environment? = {
        Environment.loadInfoDictionaryConfiguration("Development")
    }()

    private static func loadInfoDictionaryConfiguration(_ environmentName: String, from bundle: Bundle = Bundle.main) -> Environment? {
        guard
            let oauthEnvironments = bundle.object(forInfoDictionaryKey: "OAuth Environments") as? [String: [String: String]],
            let developmentEnvironment = oauthEnvironments[environmentName],
            let baseURLString = developmentEnvironment["Base URL"],
            let baseURL = URL(string: baseURLString),
            let consumerKey = developmentEnvironment["Consumer Key"],
            !consumerKey.isEmpty,
            let consumerSecret = developmentEnvironment["Consumer Secret"],
            !consumerSecret.isEmpty
        else {
            return nil
        }

        return Environment(apiBaseURL: baseURL,
                           oauthBaseURL: baseURL,
                           oauthConsumerKey: consumerKey,
                           oauthConsumerSecret: consumerSecret)
    }
}
