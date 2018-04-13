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
    let key: String
    let value: String?
    let description: String?

    var tag: String {
        if let value = value {
            return "\(key)=\(value)"
        } else {
            return key
        }
    }

    var isMissingValue: Bool {
        return value?.isEmpty ?? true
    }
}

protocol TagProviding {
    func wikiPage(key: String, value: String?) -> WikiPage?
    func wikiPages(matching searchText: String, completion: @escaping (_: String, _: [WikiPage]) -> Void)

    func potentialValues(key: String) -> [String]
}

class SQLiteTagProvider: NSObject, TagProviding {
    let db: Connection

    init?(databasePath: String) {
        do {
            db = try Connection(databasePath, readonly: true)
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

                return WikiPage(key: key, value: value, description: description)
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

    func wikiPages(matching searchText: String, completion: @escaping (String, [WikiPage]) -> Void) {
        let query = """
        SELECT
            COALESCE(
                (
                    SELECT
                        lang_count
                    FROM
                        wikipages_tags
                    WHERE
                        wikipages_tags.key = w.key
                        AND
                        (
                            wikipages_tags.value = w.value
                            OR
                            wikipages_tags.value IS NULL AND w.value IS NULL
                        )

                ), 0
            ) AS number_of_translations,
            w.key,
            w.value,
            w.description,
            w.image,
            w.tags_combination,
            w.tags_linked,
            w.lang
        FROM
            wikipages w
        WHERE
            w.on_node = 1
            AND
            ((w.lang = "en" AND w.description IS NOT NULL) OR w.lang = "en")
            AND
            (
                w.tag LIKE ?1
                OR
                w.key LIKE ?1
                OR
                w.value LIKE ?1
                OR
                w.description LIKE ?1
            )
        GROUP BY
            w.tag
        ORDER BY
            number_of_translations DESC,
            w.key DESC
        """

        let searchTextForLikeQuery = "%\(searchText)%"

        DispatchQueue.global(qos: .background).async {
            var pages = [WikiPage]()
            do {
                for row in try self.db.prepare(query, [searchTextForLikeQuery]) {
                    guard let key = row[1] as? String else {
                        // We need to at least have a key.
                        print("Skipping row, as it has no key: \(row)")
                        continue
                    }

                    let value = row[2] as? String
                    let description = row[3] as? String

                    let singlePage = WikiPage(key: key, value: value, description: description)

                    pages.append(singlePage)
                }
            } catch {
                // Ignore the error.
            }

            DispatchQueue.main.async {
                completion(searchText, pages)
            }
        }
    }
}
