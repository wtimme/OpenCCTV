//
//  OverpassRelation+AEXMLElement.swift
//  SwiftOverpass
//
//  Created by Wolfgang Timme on 5/17/18.
//  Copyright © 2018 Sho Kamei. All rights reserved.
//

import Foundation

import AEXML

extension OverpassRelation {
    
    /// Attempts to create an Overpass relation from the given XML element.
    ///
    /// - Parameters:
    ///   - xmlElement: The XML element to create the relation from.
    ///   - response: Overpass response object that can be used to lookup related features.
    convenience init?(xmlElement: AEXMLElement, response: OverpassResponse) {
        
        // Basic entity properties
        guard let id = OverpassEntity.parseEntityId(from: xmlElement) else {
            return nil
        }
        let tags = OverpassEntity.parseTags(from: xmlElement)
        let meta = OverpassEntity.parseMeta(from: xmlElement)
        
        let members: [OverpassRelation.Member]
        if let memberXMLElements = xmlElement["member"].all {
            
            // A mapping of the XML attribute "type" to the cases of `OverpassQueryType`
            let typeAttributeToTypeEnum: [String: OverpassQueryType] = ["node": .node,
                                                                        "way": .way,
                                                                        "relation": .relation]
            
            members = memberXMLElements.compactMap {
                guard
                    let typeAttribute = $0.attributes["type"],
                    let type = typeAttributeToTypeEnum[typeAttribute]
                else {
                    // The member is of an unexpected type; ignore it.
                    return nil
                }
                
                guard let id = $0.attributes["ref"] else {
                    // Members must have an ID.
                    return nil
                }
                
                let role = $0.attributes["role"]
                return OverpassRelation.Member(type: type, id: id, role: role)
            }
        } else {
            members = []
        }
        
        self.init(id: id, members: members, tags: tags, meta: meta, response: response)
    }
    
}
