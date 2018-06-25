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
    var oauthHandlerMock: OAuthHandlerMock!
    var client: APIClientProtocol!
    
    override func setUp() {
        super.setUp()
        
        oauthHandlerMock = OAuthHandlerMock()
        client = APIClient(baseURL: baseURL, oauthHandler: oauthHandlerMock)
    }
    
    // MARK: OAuth
    
    func testStartOAuthFlowImmediatelyExecuteTheClosureIfTheOAuthHandlerExperiencedAnError() {
        let presentingViewController = UIViewController()
        
        // Set up the OAuth handler to execute the closure with a mocked error.
        let mockedError = MockError(code: 1)
        oauthHandlerMock.authorizationError = mockedError
        
        let closureExpectation = expectation(description: "The closure should be executed.")
        client.addAccountUsingOAuth(from: presentingViewController) { (error) in
            XCTAssertEqual(error as? MockError, mockedError)
            
            closureExpectation.fulfill()
        }
        wait(for: [closureExpectation], timeout: 0.5)
    }
    
}
