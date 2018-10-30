//
//  GenericListViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 25/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

final class GenericListViewController<T>: UITableViewController, ErrorPresenting, UISearchResultsUpdating {
    
    private let interactor: GenericListInteractor<T>
    private let configure: (GenericCell, T) -> Void
    private let select: (T) -> Void
    private var searchController: UISearchController?
    
    init(interactor: GenericListInteractor<T>, configure: @escaping (GenericCell, T) -> Void, select: @escaping (T) -> Void) {
        self.interactor = interactor
        self.configure = configure
        self.select = select
        super.init(nibName: nil, bundle: nil)
        
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchBar.placeholder = "Поиск"
        searchController?.searchBar.tintColor = .white
        searchController?.searchBar.textField?.textColor = .white
        searchController?.searchResultsUpdater = self
        searchController?.obscuresBackgroundDuringPresentation = false
        
        definesPresentationContext = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = UIView()
        tableView.separatorColor = UIColor(r: 47, g: 53, b: 73)
        tableView.backgroundColor = UIColor(r: 37, g: 42, b: 57)
        tableView.tableFooterView = UIView()
        tableView.register(GenericCell.nib, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 52
        tableView.rowHeight = UITableView.automaticDimension
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            searchController?.searchBar.searchBarStyle = .minimal
            searchController?.searchBar.backgroundColor = tableView.backgroundColor
            tableView.tableHeaderView = searchController?.searchBar
        }
        
        setLoading(true)
        interactor.loadData { [weak self] in
            self?.setLoading(false)
            switch $0 {
            case .success(let result):
                self?.data = result
            case .failure(let error):
                self?.showError(error)
            }
        }
    }
    
    // MARK: - Managing Data
    
    private var data: [T]? {
        didSet {
            updateFilteredData()
            tableView.reloadData()
        }
    }
    
    private var filteredData: [T]?
    
    private func updateFilteredData() {
        if let searchTerm = searchTerm?.trimmingCharacters(in: CharacterSet.whitespaces), searchTerm.count > 0 {
            filteredData = data?.filter { String(describing: $0).localizedCaseInsensitiveContains(searchTerm) }
        } else {
            filteredData = data
        }
    }
    
    private var searchTerm: String? {
        didSet {
            updateFilteredData()
            tableView.reloadData()
        }
    }
    
    // MARK: - Loading
    
    private func setLoading(_ loading: Bool) {
        if loading {
            let spinner = UIActivityIndicatorView(style: .white)
            spinner.startAnimating()
            tableView.tableFooterView = spinner
        } else {
            tableView.tableFooterView = nil
        }
    }
    
    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        if let cell = cell as? GenericCell, let object = filteredData?[indexPath.row] {
            configure(cell, object)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let object = filteredData?[indexPath.row] else { return }
        select(object)
    }
    
    // MARK: - Search Results Updating
    
    func updateSearchResults(for searchController: UISearchController) {
        searchTerm = searchController.searchBar.text
    }
    
}
