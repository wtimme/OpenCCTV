//
//  KeychainHandler.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/9/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

import KeychainAccess

enum ItemKeyEntry: String {
    case oauthToken
    case oauthTokenSecret
}

protocol KeychainHandling {
    /// Returns the stored value for the given key.
    ///
    /// - Parameter key: The key to get the value for.
    /// - Returns: The string value for the given key.
    func get(_ key: ItemKeyEntry) -> String?

    /// Sets/update the value of the key.
    ///
    /// - Parameters:
    ///   - key: The key to set the value for.
    ///   - value: The value to set for the key.
    func set(key: ItemKeyEntry, value: String?)

    /// Convenience method for invoking `set(key:value:)` with a `nil` value.
    ///
    /// - Parameter key: The key to remove the value for.
    func removeValue(for key: ItemKeyEntry)
}

class KeychainAccessKeychainHandler: NSObject, KeychainHandling {
    private let keychain: Keychain

    init(service: String = "de.wtimme.osm-completionist.dev") {
        keychain = Keychain(service: service)
    }

    // MARK: KeychainHandling

    func get(_ key: ItemKeyEntry) -> String? {
        return keychain[key.rawValue]
    }

    func set(key: ItemKeyEntry, value: String?) {
        keychain[key.rawValue] = value
    }

    func removeValue(for key: ItemKeyEntry) {
        set(key: key, value: nil)
    }
}
