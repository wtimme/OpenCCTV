//
//  OSMTagProvider.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/10/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

import SQLite

struct Tag {
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
    func findSingleTag(_ parameters: (key: String, value: String?), _ completion: @escaping ((key: String, value: String?), Tag?) -> Void)
    func findTags(matching searchTerm: String, _ completion: @escaping ((key: String, value: String?), [Tag]) -> Void)

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

    func findSingleTag(_ parameters: (key: String, value: String?), _ completion: @escaping ((key: String, value: String?), Tag?) -> Void) {
        findTags(parameters, exactMatch: true) { parameters, tags in
            completion(parameters, tags.first)
        }
    }

    func findTags(matching searchTerm: String, _ completion: @escaping ((key: String, value: String?), [Tag]) -> Void) {
        findTags((key: searchTerm, value: searchTerm), exactMatch: false, completion)
    }

    private func findTags(_ parameters: (key: String, value: String?), exactMatch: Bool, _ completion: @escaping ((key: String, value: String?), [Tag]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let bindings: [Binding]
            let condition: String
            var limit: String?

            if !exactMatch {
                bindings = ["%\(parameters.key)%", "%\(parameters.value ?? parameters.key)%"]
                condition = """
                (
                    w.tag LIKE ?1
                    OR
                    w.tag LIKE ?2
                    OR
                    w.key LIKE ?1
                    OR
                    w.key LIKE ?2
                    OR
                    w.value LIKE ?1
                    OR
                    w.value LIKE ?2
                    OR
                    w.description LIKE ?1
                    OR
                    w.description LIKE ?2
                )
                """
            } else {
                if let value = parameters.value {
                    bindings = [parameters.key, value]
                    condition = """
                    (
                    w.key = ?1
                    AND
                    w.value = ?2
                    )
                    """
                } else {
                    bindings = [parameters.key]
                    condition = """
                    w.key = ?1
                    """
                }

                limit = """
                LIMIT
                1
                """
            }

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
                \(condition)
            GROUP BY
                w.tag
            ORDER BY
                number_of_translations DESC,
                w.key DESC
            \(limit ?? "")
            """

            DispatchQueue.global(qos: .background).async {
                var matchingTags = [Tag]()
                do {
                    for row in try self.db.prepare(query, bindings) {
                        guard let key = row[1] as? String else {
                            // We need to at least have a key.
                            print("Skipping row, as it has no key: \(row)")
                            continue
                        }

                        let value = row[2] as? String
                        let description = row[3] as? String

                        let tag = Tag(key: key, value: value, description: description)

                        matchingTags.append(tag)
                    }
                } catch {
                    // Ignore the error.
                }

                DispatchQueue.main.async {
                    completion(parameters, matchingTags)
                }
            }
        }
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