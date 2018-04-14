//
//  DirectionEditorViewController.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/13/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import UIKit

import SwiftLocation

class DirectionEditorViewController: UIViewController {
    
    var tag: Tag!
    
    @IBOutlet var directionLabel: UILabel!
    
    private var headingString: String = "0" {
        didSet {
            directionLabel.text = "\(headingString)°"
        }
    }
    
    private var headingRequest: HeadingRequest?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        headingRequest = Locator.subscribeHeadingUpdates(accuracy: 30, onUpdate: { (heading) -> (Void) in
            self.headingString = String(format: "%.0f", heading.trueHeading)
        }) { (serviceState) -> (Void) in
            print("Failed to update heading: \(serviceState)")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        headingRequest?.stop()
    }

}
