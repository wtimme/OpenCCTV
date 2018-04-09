//
//  Environment.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/9/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

struct Environment {
    // OAuth
    let oauthBaseURL: URL
    let oauthConsumerKey: String
    let oauthConsumerSecret: String
}

extension Environment {
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

        return Environment(oauthBaseURL: baseURL,
                           oauthConsumerKey: consumerKey,
                           oauthConsumerSecret: consumerSecret)
    }
}
