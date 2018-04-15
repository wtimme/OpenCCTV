//
//  ChangesViewController.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/14/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Eureka

class ChangesViewController: FormViewController {
    
    var changeHandler: OSMChangeHandling!
    var nodeDataProvider: OSMDataProviding!
    private var viewModel: ChangeReviewViewModel!
    
    @IBOutlet var uploadBarButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = ChangeReviewViewModel(changeHandler: changeHandler,
                                          nodeDataProvider: nodeDataProvider)
        viewModel.delegate = self
        
        setupForm()
        
        uploadBarButtonItem.isEnabled = viewModel.isUploadButtonEnabled
    }
    
    private func setupForm() {
        if viewModel.isExplanatorySectionVisible {
            form +++ Section("No changes yet")
                <<< LabelRow {
                    $0.title = """
                    Changes to nodes will appear here. You can review and edit them before uploading them to OpenStreetMap.
                    """
                    $0.cell.textLabel?.numberOfLines = 0
                }
        } else {
            let nodeDiffs = changeHandler.changedNodes.values.map { (node) -> NodeDiff in
                return NodeDiff(node: node, originalNode: nodeDataProvider.node(id: node.id))
            }
            
            for diff in nodeDiffs {
                form +++ makeNodeDiffSection(diff)
            }
            
            form +++ Section(header: "Commit message", footer: "Specifying a useful commit message helps other mappers review and understand your changes.")
                <<< TextAreaRow {
                    $0.placeholder = "Add tags to a couple of nodes"
            }
        }
    }
    
    private func makeNodeDiffSection(_ diff: NodeDiff) -> Section {
        let sectionTitle = "Node \(diff.nodeId)"
        
        let nodeSection = Section(sectionTitle)
        
        nodeSection
            <<< SwitchRow {
                $0.title = "Include in changeset"
                $0.value = true
            }
    
        for (key, value) in diff.addedTags {
            nodeSection
                <<< LabelRow {
                    $0.title = "Add"
                    $0.value = "\(key)=\(value)"
            }
        }
        
        for (key, value) in diff.updatedTags {
            nodeSection
                <<< LabelRow {
                    $0.title = "Updated"
                    $0.value = "\(key)=\(value)"
            }
        }
        
        for (key, value) in diff.removedTags {
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
                    self.viewModel.presentDetailsForNode(id: diff.nodeId)
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

extension ChangesViewController: ChangeReviewViewModelDelegate {
    
    func showDetailsForNode(_ node: Node) {
        self.performSegue(withIdentifier: "ShowNodeDetails", sender: node)
    }
    
}
