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

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                            target: self,
                                                            action: #selector(didTapShareButton(_:)))

        setupForm()
    }

    private func setupForm() {
        form +++ Section("Basic Data")
            <<< LabelRow {
                $0.title = "Node ID"
                $0.value = "\(node.id)"
            }

        for tag in node.tags {
            let tagSection = Section()

            tagSection
                <<< LabelRow {
                    $0.title = tag.key
                    $0.value = tag.value
                    $0.cell.accessoryType = .disclosureIndicator
                }

            if let description = tagProvider?.wikiPage(key: tag.key, value: tag.value, language: "en")?.description {
                tagSection
                    <<< LabelRow {
                        $0.title = description
                    }
            }

            tagSection
                <<< ButtonRow {
                    $0.title = "Remove Tag"
                }

            form +++ tagSection

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
    }

    @objc func didTapShareButton(_: Any?) {
        guard let nodeDetailsURL = URL(string: "https://www.openstreetmap.org/node/\(node.id)") else {
            return
        }

        let activityViewController = UIActivityViewController(activityItems: [nodeDetailsURL], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
}
