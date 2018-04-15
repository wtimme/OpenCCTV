//
//  ChangesViewController.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/14/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Eureka

class ChangesViewController: FormViewController {
    
    var changeHandler: OSMChangeHandling! {
        didSet {
            viewModel = ChangeReviewViewModel(changeHandler: changeHandler)
        }
    }
    var nodeDataProvider: OSMDataProviding!
    
    private var viewModel: ChangeReviewViewModel!
    
    @IBOutlet var uploadBarButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupForm()
        
        uploadBarButtonItem.isEnabled = viewModel.isUploadButtonEnabled
    }
    
    private func setupForm() {
        for node in changeHandler.changedNodes.values {
            form +++ makeNodeSection(node: node)
        }
        
        form +++ Section(header: "Commit message", footer: "Specifying a useful commit message helps other mappers review and understand your changes.")
            <<< TextAreaRow {
                $0.placeholder = "Add tags to a couple of nodes"
            }
    }
    
    private func makeNodeSection(node: Node) -> Section {
        let sectionTitle = "Node \(node.id)"
        
        let nodeSection = Section(sectionTitle)
        
        nodeSection
            <<< SwitchRow {
                $0.title = "Include in changeset"
                $0.value = true
            }
    
        var addedTags = [String: String]()
        var updatedTags = [String: String]()
        var removedTags = [String: String]()
        
        if let originalNode = nodeDataProvider.node(id: node.id) {
            
            addedTags = node.rawTags.filter({ (key, value) -> Bool in
                return nil == originalNode.rawTags[key]
            })
            
            updatedTags = node.rawTags.filter({ (key, value) -> Bool in
                guard let originalValue = originalNode.rawTags[key] else { return false }
                
                return originalValue != value
            })
            
            removedTags = originalNode.rawTags.filter({ (key, value) -> Bool in
                return nil == node.rawTags[key]
            })
        } else {
            // All tags are new.
            addedTags = node.rawTags
        }
        
        for (key, value) in addedTags {
            nodeSection
                <<< LabelRow {
                    $0.title = "Add"
                    $0.value = "\(key)=\(value)"
            }
        }
        
        for (key, value) in updatedTags {
            nodeSection
                <<< LabelRow {
                    $0.title = "Updated"
                    $0.value = "\(key)=\(value)"
            }
        }
        
        for (key, value) in removedTags {
            nodeSection
                <<< LabelRow {
                    $0.title = "Removed"
                    $0.value = "\(key)=\(value)"
            }
        }
        
        nodeSection
            <<< ButtonRow {
                $0.title = "Node Details"
                $0.onCellSelection({ (_, _) in
                    self.performSegue(withIdentifier: "ShowNodeDetails", sender: node)
                })
            }
        
        return nodeSection
    }
    
    @IBAction func didTapCancelButton() {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if
            segue.identifier == "ShowNodeDetails",
            let node = sender as? Node,
            let formViewController = segue.destination as? NodeFormViewController
        {
            formViewController.node = node
            formViewController.changeHandler = changeHandler
        }
    }

}
