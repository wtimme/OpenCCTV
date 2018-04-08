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
import SwiftOverpass

class NodeFormViewController: FormViewController {
    let node: OverpassNode

    init(node: OverpassNode) {
        self.node = node

        super.init(style: .grouped)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Node Details"

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(icon: .ionicons(.earth), size: CGSize(width: 30, height: 30)),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didTapOpenOnOpenStreetMapButton(_:)))

        form +++ Section("Basic Data")
            <<< IntRow { row in
                row.title = "Node ID"
                row.disabled = true
                row.value = Int(node.id)!
            }

        let tagSection = Section("Tags")
        for tag in node.tags {
            tagSection
                <<< TextRow { row in
                    row.title = tag.key
                    row.value = tag.value
                }
        }
        form +++ tagSection
    }

    @objc func didTapOpenOnOpenStreetMapButton(_: Any?) {
        guard let nodeDetailsURL = URL(string: "https://www.openstreetmap.org/node/\(Int(node.id)!)") else {
            return
        }

        let safariViewController = SFSafariViewController(url: nodeDetailsURL)

        present(safariViewController, animated: true)
    }
}
