//
//  APIClientTestCase.swift
//  OSMSwift_Tests
//
//  Created by Wolfgang Timme on 6/25/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest

import OSMSwift

class APIClientTestCase: XCTestCase {
    
    let baseURL = URL(string: "https://localhost/")!
    var keychainHandlerMock: KeychainHandlerMock!
    var oauthHandlerMock: OAuthHandlerMock!
    var client: APIClientProtocol!
    
    override func setUp() {
        super.setUp()
        
        keychainHandlerMock = KeychainHandlerMock()
        oauthHandlerMock = OAuthHandlerMock()
        client = APIClient(baseURL: baseURL,
                           keychainHandler: keychainHandlerMock,
                           oauthHandler: oauthHandlerMock)
    }
    
    // MARK: OAuth
    
    func testStartOAuthFlowImmediatelyExecuteTheClosureIfTheOAuthHandlerExperiencedAnError() {
        let presentingViewController = UIViewController()
        
        // Set up the OAuth handler to execute the closure with a mocked error.
        let mockedError = MockError(code: 1)
        oauthHandlerMock.startOAuthFlowCredentialsError = mockedError
        
        let closureExpectation = expectation(description: "The closure should be executed.")
        client.addAccountUsingOAuth(from: presentingViewController) { (error) in
            XCTAssertEqual(error as? MockError, mockedError)
            
            closureExpectation.fulfill()
        }
        wait(for: [closureExpectation], timeout: 0.5)
    }
    
    func testStartOAuthFlowShouldStoreTheCredentialsInTheKeychainIfAuthenticationSucceeded() {
        let presentingViewController = UIViewController()
        
        // Act as if the OAuth handler responded with credentials.
        let mockedCredentials = OAuthCredentials(token: "sample-token",
                                                 secret: "sample-secret")
        oauthHandlerMock.startOAuthFlowCredentials = mockedCredentials
        
        let closureExpectation = expectation(description: "The closure should be executed.")
        client.addAccountUsingOAuth(from: presentingViewController) { (error) in
            XCTAssertNil(error)
            
            closureExpectation.fulfill()
        }
        wait(for: [closureExpectation], timeout: 0.5)
        
        XCTAssertEqual(keychainHandlerMock.oauthCredentials,
                       mockedCredentials,
                       "The client should store the credentials in the Keychain.")
    }
    
}
