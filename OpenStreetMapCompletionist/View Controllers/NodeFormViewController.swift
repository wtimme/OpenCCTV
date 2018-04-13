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
    var node: Node!

    let tagProvider: TagProviding? = {
        guard let databasePath = Bundle.main.path(forResource: "taginfo-wiki", ofType: "db") else {
            return nil
        }

        return SQLiteTagProvider(databasePath: databasePath)
    }()

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

        for keyValueTag in node.tags {
            guard let tag = tagProvider?.wikiPage(key: keyValueTag.key, value: keyValueTag.value) else {
                continue
            }

            form +++ tagSection(tag: tag)
        }

        form +++ Section()
            <<< LabelRow {
                $0.title = "Add Tag"
                $0.cell.accessoryType = .disclosureIndicator
                $0.onCellSelection({ _, _ in
                    self.performSegue(withIdentifier: "ShowTagSearch", sender: nil)
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

    private func tagSection(tag: WikiPage) -> Section {
        let section = Section(footer: tag.description ?? "")

        if let potentialValues = tagProvider?.potentialValues(key: tag.key), !potentialValues.isEmpty {
            section
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
            section
                <<< TextRow {
                    $0.title = tag.key
                    $0.value = tag.value
                }
        }

        return section
    }

    private func addTagSectionToForm(tag: WikiPage) {
        let indexOfNewSection = form.allSections.count - 2

        form.insert(tagSection(tag: tag), at: indexOfNewSection)
    }

    @IBAction func didTapDoneButton(_: UIControl) {
        dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if
            segue.identifier == "ShowTagSearch",
            let destinationViewController = segue.destination as? TagListTableViewController,
            let tagProvider = tagProvider {
            destinationViewController.tagProvider = tagProvider
            destinationViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension NodeFormViewController: TagSelectionDelegate {
    func tagSelectionDidFinish(with tag: WikiPage?) {
        navigationController?.popToViewController(self, animated: true)

        if let selectedTag = tag {
            addTagSectionToForm(tag: selectedTag)
        }
    }
}
