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
    private var tags = [String: Tag]()

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

    private func makeTagSections(_ keyValueTags: [String: String]) -> [Section] {
        var sections = [Section]()

        for (key, value) in keyValueTags {
            let tagSection = Section(footer: "Searching wiki for details...") {
                $0.tag = sectionTag(key)
            }
                <<< LabelRow {
                    $0.tag = key
                    $0.title = key
                    $0.value = value
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
            tagProvider?.findSingleTag((key: key, value: value), { [weak self] requestedRawTag, resolvedTag in
                if let tag = resolvedTag {
                    self?.tags[tag.key] = tag
                }

                self?.updateTagDetails(rawTag: requestedRawTag, resolvedTag: resolvedTag)
            })
        }

        return sections
    }

    private func updateTagDetails(rawTag: (key: String, value: String?), resolvedTag: Tag?) {
        guard let section = form.sectionBy(tag: sectionTag(rawTag.key)) else { return }

        section.footer?.title = resolvedTag?.description ?? ""
        section.reload()
    }
    
    private func sectionTag(_ tag: Tag) -> String {
        return sectionTag(tag.key)
    }
    
    private func sectionTag(_ key: String) -> String {
        return "\(key)_section"
    }

    private func makeSection(tag: Tag) -> Section {
        let section = Section(footer: tag.description ?? "")
        section.tag = sectionTag(tag)

        if let potentialValues = tagProvider?.potentialValues(key: tag.key), !potentialValues.isEmpty {
            section
                <<< LabelRow {
                    $0.tag = tag.key
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
                    $0.tag = tag.key
                    $0.title = tag.key
                    $0.value = tag.value
                }
        }

        return section
    }

    private func addTagSectionToForm(tag: Tag) {
        let indexOfNewSection = form.allSections.count - 2

        form.insert(makeSection(tag: tag), at: indexOfNewSection)
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
            
            if let row = form.rowBy(tag: "\(selectedTag.key)_value") as? TextRow {
                row.cell.textField.becomeFirstResponder()
            }
        }
    }
}
