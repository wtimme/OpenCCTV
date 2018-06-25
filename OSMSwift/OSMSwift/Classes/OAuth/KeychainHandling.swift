//
//  OAuthHandling.swift
//  OSMSwift
//
//  Created by Wolfgang Timme on 6/25/18.
//

import Foundation

public protocol KeychainHandling {
    
    var oauthCredentials: OAuthCredentials? { get set }
    
}
