//
//  MenuFormViewController.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/9/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Eureka

import OSMSwift

class MenuFormViewController: FormViewController {
    
    let osmClient: APIClientProtocol

    static let OAuthSectionTag = "OAuthSectionTag"

    required init?(coder aDecoder: NSCoder) {
        
        let apiBaseURL = Environment.current.apiBaseURL
        let keychainHandler = KeychainAccessKeychainHandler(apiBaseURL: apiBaseURL)
        let oauthHandler = OAuthSwiftOAuthHandler(baseURL: apiBaseURL,
                                                           consumerKey: Environment.current.oauthConsumerKey,
                                                           consumerSecret: Environment.current.oauthConsumerSecret)
        let httpRequestHandler = AlamofireHTTPRequestHandler()
        osmClient = APIClient(baseURL: apiBaseURL,
                                       keychainHandler: keychainHandler,
                                       oauthHandler: oauthHandler,
                                       httpRequestHandler: httpRequestHandler)

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let oauthSection = Section("OpenStreetMap") { section in
            section.tag = MenuFormViewController.OAuthSectionTag
        }

        oauthSection <<< LabelRow { row in
            row.title = "Status"
            row.value = osmClient.isAuthenticated ? "Authenticated" : "Not authenticated"
            row.cellUpdate({ [weak self] cell, _ in
                cell.detailTextLabel?.text = self?.osmClient.isAuthenticated ?? false ? "Authenticated ✔️" : "Not authenticated"
            })
        }

        oauthSection <<< ButtonRow { row in
            row.title = osmClient.isAuthenticated ? "Log out" : "Log in"
            row.cellUpdate({ [weak self] cell, _ in
                cell.textLabel?.text = self?.osmClient.isAuthenticated ?? false ? "Log out" : "Log in"
            })
            row.onCellSelection({ [weak self] _, _ in
                if self?.osmClient.isAuthenticated ?? false {
                    self?.performLogout()
                } else {
                    self?.performLogin()
                }
            })
        }

        form +++ oauthSection
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        form.sectionBy(tag: MenuFormViewController.OAuthSectionTag)?.reload()
    }

    @IBAction func didTapDoneButton() {
        dismiss(animated: true, completion: nil)
    }
    
    private func performLogin() {
        osmClient.addAccountUsingOAuth(from: self, { [weak self] (error) in
            guard nil == error else {
                let alertController = UIAlertController(title: error?.localizedDescription,
                                                        message: nil,
                                                        preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default,
                                                        handler: nil))
                return
            }
            
            self?.form.sectionBy(tag: MenuFormViewController.OAuthSectionTag)?.reload()
        })
    }

    private func performLogout() {
        osmClient.logout()

        form.sectionBy(tag: MenuFormViewController.OAuthSectionTag)?.reload()
    }
}
