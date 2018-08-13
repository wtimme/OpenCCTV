//
//  KeychainAccessKeychainHandler.swift
//  OSMSwift
//
//  Created by Wolfgang Timme on 6/26/18.
//

import Foundation

import KeychainAccess

public class WolleExample: NSObject {
    public override init() {
        
    }
    // foo
}

public class KeychainAccessKeychainHandler: NSObject, KeychainHandling {
    
    enum ItemKeyEntry: String {
        case token
        case secret
    }
    
    private let keychain: Keychain
    
    init(service: String) {
        keychain = Keychain(service: service)
    }
    
    public convenience init(apiBaseURL: URL) {
        let keychainService = apiBaseURL.host ?? "de.wtimme.OSMSwift"
        
        self.init(service: keychainService)
    }
    
    // MARK: KeychainHandling
    
    public var oauthCredentials: OAuthCredentials? {
        guard let token = get(.token), let secret = get(.secret) else {
            return nil
        }
        
        return OAuthCredentials(token: token, secret: secret)
    }
    
    public func setCredentials(_ credentials: OAuthCredentials?) {
        set(key: .token, value: credentials?.token)
        set(key: .secret, value: credentials?.secret)
    }
    
    // MARK: Private
    
    private func get(_ key: ItemKeyEntry) -> String? {
        return keychain[key.rawValue]
    }
    
    private func set(key: ItemKeyEntry, value: String?) {
        keychain[key.rawValue] = value
    }
    
    private func removeValue(for key: ItemKeyEntry) {
        set(key: key, value: nil)
    }
}
