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
    func wikiPage(key: String, value: String, language: String) -> WikiPage?
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

    func wikiPage(key: String, value: String, language: String) -> WikiPage? {
        do {
            for row in try db.prepare("SELECT description FROM wikipages WHERE key = '\(key)' AND value = '\(value)' AND lang = '\(language)'") {
                guard let description = row[0] as? String, !description.isEmpty else {
                    continue
                }

                return WikiPage(description: description)
            }

            return nil
        } catch {
            return nil
        }
    }
}
