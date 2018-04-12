//
//  NodeFormViewController.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/7/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Eureka

import SafariServices
import SwiftIcons

class NodeFormViewController: FormViewController {
    let node: Node
    let tagProvider: TagProviding? = {
        guard let databasePath = Bundle.main.path(forResource: "taginfo-wiki", ofType: "db") else {
            return nil
        }

        return SQLiteTagProvider(databasePath: databasePath)
    }()

    init(node: Node) {
        self.node = node

        super.init(style: .grouped)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Node Details"

        setupForm()
    }

    private func setupForm() {
        form +++ Section("Basic Data")
            <<< LabelRow {
                $0.title = "Node ID"
                $0.value = "\(node.id)"
            }
            <<< LabelRow {
                $0.title = "Latitude"
                $0.value = "\(node.coordinate.latitude)"
            }
            <<< LabelRow {
                $0.title = "Longitude"
                $0.value = "\(node.coordinate.longitude)"
            }

        for tag in node.tags {
            let sectionFooter: String
            if let description = tagProvider?.wikiPage(key: tag.key, value: tag.value)?.description {
                sectionFooter = description
            } else {
                sectionFooter = ""
            }

            let tagDetailsSection = Section(footer: sectionFooter)

            if let potentialValues = tagProvider?.potentialValues(key: tag.key), !potentialValues.isEmpty {
                tagDetailsSection
                    <<< PushRow<String>() {
                        $0.title = tag.key
                        $0.cell.accessoryType = .disclosureIndicator
                        $0.selectorTitle = "Change \(tag.key)"
                        $0.options = potentialValues
                        $0.value = tag.value
                        $0.cellUpdate({ _, row in
                            row.section?.footer?.title = self.tagProvider?.wikiPage(key: tag.key, value: row.value)?.description
                        })
                    }
            } else {
                tagDetailsSection
                    <<< TextRow {
                        $0.title = tag.key
                        $0.value = tag.value
                    }
            }

            form +++ tagDetailsSection
        }

        form +++ Section()
            <<< LabelRow {
                $0.title = "Add Tag"
                $0.cell.accessoryType = .disclosureIndicator
                $0.onCellSelection({ _, _ in
                    self.didTapAddTag()
                })
            }

        if let nodeDetailsURL = URL(string: "https://www.openstreetmap.org/node/\(node.id)") {
            form +++ Section()
                <<< ButtonRow {
                    $0.title = "View on OpenStreetMap"
                    $0.onCellSelection({ _, _ in
                        let safariViewController = SFSafariViewController(url: nodeDetailsURL)

                        self.present(safariViewController, animated: true)
                    })
                }
        }
    }

    private func didTapAddTag() {
        print("TODO: Show key/value search")
    }
}
