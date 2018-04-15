//
//  ChangeReviewViewModel.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/15/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

class ChangeReviewViewModel: NSObject {
    
    let changeHandler: OSMChangeHandling
    
    init(changeHandler: OSMChangeHandling) {
        self.changeHandler = changeHandler
    }
    
    var isUploadButtonEnabled: Bool {
        return 0 < changeHandler.changedNodes.count
    }

}
