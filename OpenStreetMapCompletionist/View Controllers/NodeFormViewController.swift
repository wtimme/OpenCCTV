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
    
    var changeHandler: OSMChangeHandling?

    let tagProvider: TagProviding? = {
        guard let databasePath = Bundle.main.path(forResource: "taginfo-wiki", ofType: "db") else {
            return nil
        }

        return SQLiteTagProvider(databasePath: databasePath)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Camera Details"

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

        for (key, value) in node.rawTags {
            form +++ makeRawTagSection(key: key, value: value)
        }

//        form +++ Section()
//            <<< LabelRow {
//                $0.title = "Add Tag"
//                $0.cell.accessoryType = .disclosureIndicator
//                $0.onCellSelection({ _, _ in
//                    self.performSegue(withIdentifier: "ShowTagSearch", sender: nil)
//                })
//            }

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

    private func makeRawTagSection(key: String, value: String?) -> Section {
        let tagSection = Section(footer: "Searching wiki for details...") {
            $0.tag = sectionTag(key)
        }
        
        tagSection
            <<< LabelRow {
                $0.tag = key
                $0.title = key
                $0.value = value
        }
        
        // Start searching for details.
        tagProvider?.findSingleTag((key: key, value: value), { [weak self] requestedRawTag, resolvedTag in
            if let tag = resolvedTag {
                self?.tags[tag.key] = tag
            }
            
            self?.updateTagDetails(rawTag: requestedRawTag, resolvedTag: resolvedTag)
        })
        
        return tagSection
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

        section
            <<< LabelRow {
                $0.tag = tag.key
                $0.title = tag.key
                $0.value = tag.value
        }

        return section
    }

    private func addTagSectionToForm(tag: Tag) {
        if let existingRow = form.rowBy(tag: tag.key) {
            if let labelRow = existingRow as? LabelRow {
                labelRow.value = tag.value
                
                if let section = form.sectionBy(tag: sectionTag(tag)) {
                    section.footer?.title = tag.description
                    
                    section.reload()
                }
            }
        } else {
            let indexOfNewSection = form.allSections.count - 2
            
            form.insert(makeSection(tag: tag), at: indexOfNewSection)
        }
    }

    @IBAction func didTapDoneButton(_: UIControl) {
        let updatedNode = nodeFromForm()
        if updatedNode != node {
            changeHandler?.add(updatedNode)
        }
        
        if 1 < navigationController?.viewControllers.count ?? 1 {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func nodeFromForm() -> Node {
        var rawTags = [String: String]()
        for keyValuePair in form.values() {
            guard let value = keyValuePair.value as? String else { continue }
            
            rawTags[keyValuePair.key] = value
        }
        
        return Node(id: node.id, coordinate: node.coordinate, rawTags: rawTags, version: nil)
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
            
            if let textRow = form.rowBy(tag: selectedTag.key) as? TextRow {
                textRow.cell.textField.becomeFirstResponder()
            }
        }
    }
}
