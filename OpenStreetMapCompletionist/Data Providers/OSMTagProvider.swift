//
//  OSMTagProvider.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/10/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

import SQLite

struct WikiPage {
    let description: String
}

protocol TagProviding {
    func wikiPage(key: String, value: String?) -> WikiPage?
    func potentialValues(key: String) -> [String]
}

class SQLiteTagProvider: NSObject, TagProviding {
    let db: Connection

    init?(databasePath: String) {
        do {
            db = try Connection(databasePath)
        } catch {
            print("Unable to load database from path \(databasePath)")

            return nil
        }
    }

    // MARK: TagProviding

    func wikiPage(key: String, value: String?) -> WikiPage? {
        do {
            let query: String
            if let value = value {
                query = "SELECT description FROM wikipages WHERE key = '\(key)' AND value = '\(value)' AND lang = 'en'"
            } else {
                query = "SELECT description FROM wikipages WHERE key = '\(key)' AND lang = 'en'"
            }

            for row in try db.prepare(query) {
                guard let description = row[0] as? String, !description.isEmpty else {
                    continue
                }

                return WikiPage(description: description)
            }

            if value != nil {
                // Try to use the page for the key.
                return wikiPage(key: key, value: nil)
            }
        } catch {
            return nil
        }

        return nil
    }

    func potentialValues(key: String) -> [String] {
        var values = Set<String>()

        do {
            for row in try db.prepare("SELECT value FROM wikipages WHERE key = '\(key)' AND value NOT NULL AND lang = 'en'") {
                guard let discoveredValue = row[0] as? String, !discoveredValue.isEmpty else {
                    continue
                }

                values.insert(discoveredValue)
            }
        } catch {
            // Ignore the error.
        }

        return values.sorted()
    }
}
