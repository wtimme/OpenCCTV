//
//  TagProviderMock.swift
//  OpenStreetMapCompletionistTests
//
//  Created by Wolfgang Timme on 4/15/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

@testable import OpenStreetMapCompletionist

class TagProviderMock: NSObject, TagProviding {
    
    public private(set) var tagSearchTerm: String?
    var tags = [Tag]()
    
    func findSingleTag(_ parameters: (key: String, value: String?), _ completion: @escaping ((key: String, value: String?), Tag?) -> Void) { }
    
    func findTags(matching searchTerm: String, _ completion: @escaping (String, [Tag]) -> Void) {
        tagSearchTerm = searchTerm
        
        completion(searchTerm, tags)
    }
    
    func potentialValues(key: String) -> [String] { return [] }

}
