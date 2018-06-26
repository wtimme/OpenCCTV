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
    private var oauthHandler: OldOAuthHandling!
    
    @IBOutlet var uploadBarButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        oauthHandler = OldOAuthHandler(environment: .current,
                                    keychainHandler: OldKeychainAccessKeychainHandler())
        
        viewModel = ChangeReviewViewModel(changeHandler: changeHandler,
                                          nodeDataProvider: nodeDataProvider,
                                          oauthHandler: oauthHandler)
        viewModel.delegate = self
        
        setupForm()
        
        uploadBarButtonItem.isEnabled = viewModel.isUploadButtonEnabled
    }
    
    private static let uploadRowTag = "uploadRowTag"
    
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
            for node in changeHandler.changedNodes.values {
                form +++ makeNodeSection(node)
            }
            
            form +++ Section(header: "Commit message", footer: "Specifying a useful commit message helps other mappers review and understand your changes.")
                <<< TextAreaRow {
                    $0.placeholder = "Add tags to a couple of nodes"
            }
            
            form +++ Section()
                <<< ButtonRow {
                    $0.tag = ChangesViewController.uploadRowTag
                    $0.title = "Upload"
            }
                <<< ButtonRow {
                    $0.title = "Revert all changes"
                    $0.cell.tintColor = .red
                    $0.onCellSelection { _,_ in
                        self.viewModel.revertAllChanges()
                    }
            }
        }
    }
    
    private func makeNodeSection(_ node: Node) -> Section {
        let originalNode = nodeDataProvider.node(id: node.id)
        let diff = NodeDiff(node: node, originalNode: originalNode)
        
        return makeNodeDiffSection(diff)
    }
    
    private func makeNodeDiffSection(_ diff: NodeDiff) -> Section {
        let sectionTitle = "Node \(diff.nodeId)"
        
        let nodeSection = Section(sectionTitle) {
            $0.tag = "\(diff.nodeId)"
        }
        
        nodeSection
            <<< SwitchRow {
                $0.title = "Include in changeset"
                $0.value = viewModel.isNodeStaged(id: diff.nodeId)
                $0.onChange({ (row) in
                    let isEnabled = row.value ?? false
                    
                    if isEnabled {
                        self.viewModel.stageNode(id: diff.nodeId)
                    } else {
                        self.viewModel.unstageNode(id: diff.nodeId)
                    }
                })
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
    
    func reloadSection(for node: Node) {
        guard
            let section = form.sectionBy(tag: "\(node.id)"),
            let sectionIndex = form.index(of: section)
            else {
                return
        }
        
        // Remove the old section.
        form.remove(at: sectionIndex)
        
        // Add an updated one.
        let updatedSection = makeNodeSection(node)
        form.insert(updatedSection, at: sectionIndex)
    }
    
    
    func updateViewFromViewModel() {
        uploadBarButtonItem.isEnabled = viewModel.isUploadButtonEnabled
        
        if let uploadButtonRow = form.rowBy(tag: ChangesViewController.uploadRowTag) as? ButtonRow {
            uploadButtonRow.disabled = Condition(booleanLiteral: !viewModel.isUploadButtonEnabled)
            uploadButtonRow.evaluateDisabled()
        }
    }
    
    func showDetailsForNode(_ node: Node) {
        self.performSegue(withIdentifier: "ShowNodeDetails", sender: node)
    }
    
    func performOAuthLoginFlow(completion: @escaping (Error?) -> Void) {
        oauthHandler.authorize(from: self, completion)
    }
    
    func askForConfirmationBeforeRevertingChanges(_ completion: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "All of your changes will be lost and cannot be recovered. Are you sure that you want to continue?",
                                                message: nil,
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel) { _ in
            completion(false)
        }
        alertController.addAction(cancelAction)
        
        let confirmAction = UIAlertAction(title: "Revert all changes", style: .destructive) { _ in
            completion(true)
        }
        alertController.addAction(confirmAction)
        
        present(alertController, animated: true)
        
    }
    
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
}
