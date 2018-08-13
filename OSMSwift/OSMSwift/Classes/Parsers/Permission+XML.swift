//
//  Permission+XML.swift
//  OSMSwift
//
//  Created by Wolfgang Timme on 6/26/18.
//

import Foundation

import AEXML

extension Permission {
    
    static func parseListOfPermissions(from data: Data) -> [Permission] {
        do {
            let xmlDocument = try AEXMLDocument(xml: data)
            
            guard let permissionXMLElements = xmlDocument.root["permissions"]["permission"].all else { return [] }
            
            return permissionXMLElements.compactMap { (xmlElement) -> Permission? in
                guard let name = xmlElement.attributes["name"] else { return nil }
                
                return Permission(rawValue: name)
            }
        } catch {
            print("\(error)")
            
            return []
        }
    }
    
}
