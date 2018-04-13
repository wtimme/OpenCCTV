//
//  TagListViewModel.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/13/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Foundation

protocol TagSelectionDelegate: class {
    func tagSelectionDidFinish(with tag: WikiPage?)
}
