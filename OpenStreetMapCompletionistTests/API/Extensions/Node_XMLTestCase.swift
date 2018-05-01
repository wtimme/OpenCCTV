//
//  Node_XMLTestCase
//  OpenStreetMapCompletionistTests
//
//  Created by Wolfgang Timme on 4/23/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import XCTest

import CoreLocation

@testable import OpenStreetMapCompletionist

class Node_XMLTestCase: XCTestCase {
    
    func testInitWithXMLDataShouldParseGetNodeByIdResponse() {
        guard let xmlData = xmlDataFromFile(named: "GetNodeById") else {
            XCTFail("Failed to read test XML data.")
            return
        }
        
        guard let node = Node(xml: xmlData) else {
            XCTFail("Failed to create Node from XML")
            return
        }
        
        let expectedNode = Node(id: 1337,
                                coordinate: CLLocationCoordinate2DMake(53.2474088, 10.4098694),
                                rawTags: ["amenity": "bicycle_parking"],
                                version: 4)
        
        XCTAssertEqual(node, expectedNode)
    }

}

// MARK: Helper

extension XCTestCase {
    
    func xmlDataFromFile(named fileName: String) -> Data? {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: fileName, withExtension: "xml") else { return nil }
        
        return try? Data(contentsOf: url)
    }
    
}
