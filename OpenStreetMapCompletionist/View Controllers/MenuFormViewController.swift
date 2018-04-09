//
//  MenuFormViewController.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/9/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import Eureka

class MenuFormViewController: FormViewController {
    let oauthHandler: OAuthHandling

    static let OAuthSectionTag = "OAuthSectionTag"

    required init?(coder aDecoder: NSCoder) {
        guard let environment = Environment.development else {
            fatalError("Unable to load the environment. Please check the 'OAuth Environments' settings in the Info.plist")
            return nil
        }

        oauthHandler = OAuthHandler(environment: environment,
                                    keychainHandler: KeychainAccessKeychainHandler())

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let oauthSection = Section("OpenStreetMap") { section in
            section.tag = MenuFormViewController.OAuthSectionTag
        }

        oauthSection <<< LabelRow { row in
            row.title = "Status"
            row.value = oauthHandler.isAuthorized ? "Authenticated" : "Not authenticated"
            row.cellUpdate({ [weak self] cell, _ in
                cell.detailTextLabel?.text = self?.oauthHandler.isAuthorized ?? false ? "Authenticated ✔️" : "Not authenticated"
            })
        }

        oauthSection <<< ButtonRow { row in
            row.title = oauthHandler.isAuthorized ? "Log out" : "Log in"
            row.cellUpdate({ [weak self] cell, _ in
                cell.textLabel?.text = self?.oauthHandler.isAuthorized ?? false ? "Log out" : "Log in"
            })
            row.onCellSelection({ [weak self] _, _ in
                if self?.oauthHandler.isAuthorized ?? false {
                    self?.performLogout()
                } else {
                    self?.performLogin()
                }
            })
        }

        form +++ oauthSection
    }

    @IBAction func didTapDoneButton() {
        dismiss(animated: true, completion: nil)
    }

    private func performLogin() {
        oauthHandler.authorize(from: self) { [weak self] error in
            if let error = error {
                print("Failed to authorize: \(error.localizedDescription)")
            }

            self?.form.sectionBy(tag: MenuFormViewController.OAuthSectionTag)?.reload()
        }
    }

    private func performLogout() {
        oauthHandler.removeCredentials()

        form.sectionBy(tag: MenuFormViewController.OAuthSectionTag)?.reload()
    }
}
