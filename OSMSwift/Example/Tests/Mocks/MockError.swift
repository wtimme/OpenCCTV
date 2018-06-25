//
//  MockError.swift
//  OSMSwift_Tests
//
//  Created by Wolfgang Timme on 6/25/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

class MockError: LocalizedError, Equatable {
    
    init(code: Int) {
        self.code = code
    }
    
    // MARK: LocalizedError
    
    let code: Int
    let title = "Sample error"
    
    // MARK: Equatable
    
    static func == (lhs: MockError, rhs: MockError) -> Bool {
        return lhs.code == rhs.code
    }
    
}
