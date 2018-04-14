//
//  TagListTableViewController.swift
//  OpenStreetMapCompletionist
//
//  Created by Wolfgang Timme on 4/12/18.
//  Copyright © 2018 Wolfgang Timme. All rights reserved.
//

import UIKit

class TagListTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    let searchController = UISearchController(searchResultsController: nil)

    var tagProvider: TagProviding!
    weak var delegate: TagSelectionDelegate?

    var tagsWithExistingValue = [Tag]()
    var tagsWithoutExistingValue = [Tag]()

    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Key/Value"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if searchController.searchBar.text?.isEmpty ?? true {
            DispatchQueue.main.async {
                self.searchController.searchBar.becomeFirstResponder()
            }
        }
    }

    private func tagForRow(at indexPath: IndexPath) -> Tag? {
        if 0 == indexPath.section && indexPath.row < tagsWithExistingValue.count {
            return tagsWithExistingValue[indexPath.row]
        } else if 1 == indexPath.section && indexPath.row < tagsWithoutExistingValue.count {
            return tagsWithoutExistingValue[indexPath.row]
        }

        return nil
    }

    private func filterAndDisplay(_ tags: [Tag]) {
        tagsWithExistingValue = tags.filter { !$0.isMissingValue }
        tagsWithoutExistingValue = tags.filter { $0.isMissingValue }

        tableView.reloadData()
        tableView.scrollRectToVisible(CGRect.zero, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        return 2
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if 0 == section {
            return tagsWithExistingValue.count
        } else if 1 == section {
            return tagsWithoutExistingValue.count
        }

        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagListCell", for: indexPath)

        if let tag = tagForRow(at: indexPath) {
            if tag.isMissingValue {
                // When the user selects this tag, we'll present another view controller
                // that allows them to specify a value.
                cell.accessoryType = .disclosureIndicator
            } else {
                // The user can select this tag directly without specifying a value.
                // Tapping the accessory view will allow to view additional information on the tag.
                cell.accessoryType = .detailButton
            }

            cell.textLabel?.text = tag.tag
            cell.detailTextLabel?.text = tag.description
        } else {
            cell.textLabel?.text = nil
            cell.detailTextLabel?.text = nil
        }

        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedTag = tagForRow(at: indexPath) else { return }
        
        delegate?.tagSelectionDidFinish(with: selectedTag)
    }

    override func tableView(_: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let selectedTag = tagForRow(at: indexPath) else { return }

        performSegue(withIdentifier: "ShowTagDetails", sender: selectedTag)
    }

    // MARK: UIViewController

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectedTag: Tag?
        if let indexPath = tableView.indexPathForSelectedRow {
            selectedTag = tagForRow(at: indexPath)
        } else if let wikiPageSender = sender as? Tag {
            selectedTag = wikiPageSender
        } else {
            selectedTag = nil
        }

        guard let tag = selectedTag else {
            fatalError("Unable to find the tag for the segue.")
        }

        segue.destination.title = tag.tag
    }

    // MARK: UISearchResultsUpdating

    func updateSearchResults(for _: UISearchController) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: nil)
        perform(#selector(performSearch), with: nil, afterDelay: 0.5)
    }

    @objc private func performSearch() {
        guard
            let searchText = searchController.searchBar.text,
            !searchText.isEmpty
        else {
            searchController.searchBar.isLoading = false
            filterAndDisplay([])
            tableView.reloadData()

            // Without a search term, there's no need to start the query.
            return
        }

        // Indicate that we're loading the results.
        searchController.searchBar.isLoading = true

        tagProvider.findTags(matching: searchText) { [weak self] parameters, tags in
            guard
                let currentSearchText = self?.searchController.searchBar.text,
                currentSearchText.range(of: parameters.key) != nil,
                currentSearchText == parameters.key
            else {
                // The search text was changed; we no longer care about the result.
                return
            }

            self?.searchController.searchBar.isLoading = false

            self?.filterAndDisplay(tags)
            self?.tableView.reloadData()

            if parameters.key == self?.searchController.searchBar.text {
                // We finished loading the results for the current search term; stop indicate loading activity.
                self?.searchController.searchBar.isLoading = false
            }
        }
    }

    // MARK: UISearchBarDelegate

    func searchBarCancelButtonClicked(_: UISearchBar) {
        delegate?.tagSelectionDidFinish(with: nil)
    }
}
