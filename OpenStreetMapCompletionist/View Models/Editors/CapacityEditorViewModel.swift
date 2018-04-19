//
//  CapacityEditorViewModel.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/18/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

protocol CapacityEditorViewModelDelegate: class {
    func updateViewFromViewModel(_ viewModel: CapacityEditorViewModelProtocol)
}

protocol CapacityEditorViewModelProtocol: class {
    
    var delegate: CapacityEditorViewModelDelegate? { get set }
    
    var title: String { get }
    var question: String { get }
    
    var isSaveButtonHidden: Bool { get }
    
    var textFieldText: String? { get set }
    
    // TODO: This does not need to be public.
    var valueAsInteger: Int { get }
    
}

class CapacityEditorViewModel: NSObject, CapacityEditorViewModelProtocol {
    
    // MARK: Private
    
    // MARK: CapacityEditorViewModelProtocol
    
    weak var delegate: CapacityEditorViewModelDelegate?
    
    var title = "Bicycle Parking"
    var question = "How many bikes can be parked here?"
    
    var isSaveButtonHidden: Bool {
        return 0 == valueAsInteger
    }
    
    var textFieldText: String? {
        didSet {
            delegate?.updateViewFromViewModel(self)
        }
    }
    
    var valueAsInteger: Int {
        guard
            let text = textFieldText,
            let valueAsInteger = Int(text)
            else {
                return 0
        }
        
        return valueAsInteger
    }

}
