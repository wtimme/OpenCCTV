//
//  AppDelegate.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/4/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import UIKit

import OAuthSwift
import FTLinearActivityIndicator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        UIApplication.configureLinearNetworkActivityIndicatorIfNeeded()
    }

    func application(_: UIApplication, open url: URL, options _: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.host == "oauth-callback" {
            OAuthSwift.handle(url: url)
        }
        return true
    }
}
