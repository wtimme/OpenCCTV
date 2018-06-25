//
//  KeychainHandlerMock.swift
//  OSMSwift_Example
//
//  Created by Wolfgang Timme on 6/26/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

@testable import OSMSwift

class KeychainHandlerMock: KeychainHandling {
    
    // MARK: KeychainHandling
    
    var oauthCredentials: OAuthCredentials?

}
