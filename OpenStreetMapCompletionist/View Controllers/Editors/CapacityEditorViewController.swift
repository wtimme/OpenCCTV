//
//  CapacityEditorViewController.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/18/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import UIKit

protocol CapacityEditorViewControllerDelegate: class {
    func showDetails(for node: Node, andAdd key: String?)
}

class CapacityEditorViewController: UIViewController {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIButton!
    
    var changeHandler: OSMChangeHandling?
    var node: Node!
    
    weak var delegate: CapacityEditorViewControllerDelegate?
    
    private var viewModel: CapacityEditorViewModelProtocol!
    
    override func viewDidLoad() {
        viewModel = CapacityEditorViewModel()
        viewModel.delegate = self
        
        viewModel.textFieldText = node.rawTags["capacity"]
        
        title = viewModel.title
        questionLabel.text = viewModel.question
        
        textField.delegate = self
        
        textField.text = viewModel.textFieldText
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if textField.text?.isEmpty ?? true {
            textField.becomeFirstResponder()
        }
    }

    @IBAction func textChanged(_ sender: Any) {
        viewModel.textFieldText = textField.text
    }
    
    @IBAction func save(_ sender: Any) {
        save(valueAsString: String(format: "%d", viewModel.valueAsInteger))
    }
    
    @IBAction func cancel(_ sender: Any) {
        if nil != node.rawTags["capacity"] {
            // The tag exists, but the user wants to remove the answer.
            save(valueAsString: nil)
        } else {
            dismiss()
        }
    }
    
    private func save(valueAsString: String?) {
        
        // TODO: Move this to the view model.
        var rawTags = node.rawTags
        
        if let value = valueAsString {
            rawTags["capacity"] = value
        } else {
            rawTags.removeValue(forKey: "capacity")
        }
        
        let updatedNode = Node(id: node.id,
                               coordinate: node.coordinate,
                               rawTags: rawTags,
                               version: nil)
        changeHandler?.add(updatedNode)
        
        dismiss()
    }
    
    @IBAction func dismiss() {
        textField.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showNodeDetails(_ sender: Any) {
        delegate?.showDetails(for: node, andAdd: "capacity")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if
            segue.identifier == "ShowNodeDetails",
            let navigationController = segue.destination as? UINavigationController,
            let formViewController = navigationController.topViewController as? NodeFormViewController
        {
            formViewController.node = node
            formViewController.changeHandler = changeHandler
            
            textField.resignFirstResponder()
        }
    }
    
}

extension CapacityEditorViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updateViewFromViewModel(self.viewModel)
    }
    
}

extension CapacityEditorViewController: CapacityEditorViewModelDelegate {
    
    func updateViewFromViewModel(_ viewModel: CapacityEditorViewModelProtocol) {
        
        self.saveButton.isHidden = viewModel.isSaveButtonHidden
        self.stackView.layoutIfNeeded()
    }
    
}
