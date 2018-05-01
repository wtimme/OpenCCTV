//
//  Node_XML.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/23/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import AEXML

import CoreLocation

extension Node {
    
    init?(xml data: Data) {
        do {
            let xmlDocument = try AEXMLDocument(xml: data)
            
            let nodeElement = xmlDocument.root["node"]
            
            guard
                let idAsString = nodeElement.attributes["id"],
                let id = Int(idAsString),
                let latitudeAsString = nodeElement.attributes["lat"],
                let latitude = CLLocationDegrees(latitudeAsString),
                let longitudeAsString = nodeElement.attributes["lon"],
                let longitude = CLLocationDegrees(longitudeAsString),
                let versionAsString = nodeElement.attributes["version"],
                let version = Int(versionAsString)
            else {
                return nil
            }
            
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            
            guard CLLocationCoordinate2DIsValid(coordinate) else {
                return nil
            }
            
            var rawTags = [String: String]()
            for tagElement in nodeElement["tag"].all ?? [] {
                guard
                    let key = tagElement.attributes["k"],
                    !key.isEmpty,
                    let value = tagElement.attributes["v"],
                    !value.isEmpty
                else {
                    continue
                }
                
                rawTags[key] = value
            }
            
            self.id = id
            self.coordinate = coordinate
            self.rawTags = rawTags
            self.version = version
        } catch {
            let dataAsString = String(data: data, encoding: .utf8)
            print("Unable to create Node from XML: \(String(describing: dataAsString))")
            return nil
        }
        
    }
    
}
