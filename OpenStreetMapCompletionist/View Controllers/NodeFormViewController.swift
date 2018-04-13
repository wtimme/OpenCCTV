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
    var tags = [String: Tag]()

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

        let tagSections = makeTagSections(node.rawTags)
        form.append(contentsOf: tagSections)

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

    private func makeTagSections(_ keyValueTags: [(key: String, value: String?)]) -> [Section] {
        var sections = [Section]()

        for rawTag in keyValueTags {
            let tagSection = Section(footer: "Searching wiki for details...") {
                $0.tag = rawTag.key
            }
                <<< LabelRow {
                    $0.title = rawTag.key
                    $0.value = rawTag.value
                    $0.cell.accessoryType = .disclosureIndicator
                    $0.onCellSelection({ _, row in
                        guard let section = row.section, let tagKey = section.tag, let selectedTag = self.tags[tagKey] else {
                            return
                        }

                        self.performSegue(withIdentifier: "ShowTagDetails", sender: selectedTag)
                    })
                }

            sections.append(tagSection)

            // Start searching for details.
            tagProvider?.findSingleTag(rawTag, { [weak self] requestedRawTag, resolvedTag in
                if let tag = resolvedTag {
                    self?.tags[tag.key] = tag
                }

                self?.updateTagDetails(rawTag: requestedRawTag, resolvedTag: resolvedTag)
            })
        }

        return sections
    }

    private func updateTagDetails(rawTag: (key: String, value: String?), resolvedTag: Tag?) {
        guard let section = form.sectionBy(tag: rawTag.key) else { return }

        section.footer?.title = resolvedTag?.description ?? ""
        section.reload()
    }

    private func tagSection(tag: Tag) -> Section {
        let section = Section(footer: tag.description ?? "")

        if let potentialValues = tagProvider?.potentialValues(key: tag.key), !potentialValues.isEmpty {
            section
                <<< LabelRow {
                    $0.title = tag.key
                    $0.value = tag.value
                    $0.cell.accessoryType = .disclosureIndicator
                    $0.onCellSelection({ _, _ in
                        self.performSegue(withIdentifier: "ShowTagDetails", sender: tag)
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

    private func addTagSectionToForm(tag: Tag) {
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
        } else if
            segue.identifier == "ShowTagDetails",
            let selectedTag = sender as? Tag {
            segue.destination.title = selectedTag.tag
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension NodeFormViewController: TagSelectionDelegate {
    func tagSelectionDidFinish(with tag: Tag?) {
        navigationController?.popToViewController(self, animated: true)

        if let selectedTag = tag {
            addTagSectionToForm(tag: selectedTag)
        }
    }
}
