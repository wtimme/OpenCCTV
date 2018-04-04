//
//  ViewController.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/4/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import UIKit

import SwiftOverpass

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let query = SwiftOverpass.query(type: .node)
        query.setBoudingBox(s: 53.584245, n: 53.607651, w: 10.013931, e: 10.072253)
        query.hasTag("amenity", equals: "bicycle_parking")
        query.tags["capacity"] = OverpassTag(key: "capacity", value: ".", isNegation: true, isRegex: true)
        
        SwiftOverpass.api(endpoint: "https://overpass-api.de/api/interpreter")
            .fetch(query) { (response) in
                
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

