//
//  AddOSMAccountViewController.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 6/16/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import UIKit

class AddOSMAccountViewController: UIViewController {

    let oauthHandler: OldOAuthHandling
    
    static let OAuthSectionTag = "OAuthSectionTag"
    
    required init?(coder aDecoder: NSCoder) {
        
        oauthHandler = OldOAuthHandler(environment: .current,
                                    keychainHandler: KeychainAccessKeychainHandler())
        
        super.init(coder: aDecoder)
    }
    
    @IBAction func performLogin() {
        oauthHandler.authorize(from: self) { [weak self] error in
            if let error = error {
                print("Failed to authorize: \(error.localizedDescription)")
            } else {
                // TODO: Check permissions
                // ...
                
                self?.navigationController?.popViewController(animated: true)
            }
            
            
        }
    }

}
