//
//  AppDelegate.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/4/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import UIKit

import AlamofireNetworkActivityIndicator
import OAuthSwift
import FTLinearActivityIndicator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        setupNetworkActivityIndicator()
    }

    func application(_: UIApplication, open url: URL, options _: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.host == "oauth-callback" {
            OAuthSwift.handle(url: url)
        }
        return true
    }
    
    // MARK: Private methods
    
    private func setupNetworkActivityIndicator() {
        // Let Alamofire automatically take care of the network activity indicator's state.
        NetworkActivityIndicatorManager.shared.isEnabled = true
        
        // For iPhone X, we need display a custom network activity indicator above the battery indicator.
        UIApplication.configureLinearNetworkActivityIndicatorIfNeeded()
    }
}
