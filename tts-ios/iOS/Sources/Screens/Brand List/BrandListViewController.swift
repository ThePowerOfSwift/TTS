//
//  BrandListViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 01/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

protocol BrandListViewControllerDelegate: class {
    func brandListViewController(_ viewController: BrandListViewController, didSelectBrand brand: CarBrand)
    func brandListViewController(_ viewController: BrandListViewController, didSelectBrand brand: CarBrand, model: NamedValue)
}

final class BrandListViewController: UITableViewController, ErrorPresenting, UISearchResultsUpdating {
    
    weak var delegate: BrandListViewControllerDelegate?
    var shouldSelectModel = true
    private let interactor: BrandListInteractor
    private var searchController: UISearchController?
    
    init(interactor: BrandListInteractor) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Выбор марки"
        
        tableView.backgroundColor = UIColor(r: 37, g: 42, b: 57)
        tableView.rowHeight = 52
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor(r: 47, g: 53, b: 73)
        tableView.register(BrandCell.nib, forCellReuseIdentifier: "cell")
        
        // ensure that the search bar does not remain on the screen if the user navigates to another view controller while the UISearchController is active
        definesPresentationContext = true
        
        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchBar.placeholder = "Поиск"
        searchController?.searchBar.tintColor = .white
        searchController?.searchBar.textField?.textColor = .white
        searchController?.searchResultsUpdater = self
        searchController?.obscuresBackgroundDuringPresentation = false
        
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
    
    private var data: [CarBrand]? {
        didSet {
            updateFilteredData()
            tableView.reloadData()
        }
    }
    
    private var filteredData: [CarBrand]?
    
    private func updateFilteredData() {
        if let searchTerm = searchTerm?.trimmingCharacters(in: CharacterSet.whitespaces), searchTerm.count > 0 {
            filteredData = data?.filter { $0.name.localizedCaseInsensitiveContains(searchTerm) }
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
        if let cell = cell as? BrandCell {
            cell.item = filteredData?[indexPath.row]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let object = filteredData?[indexPath.row] else { return }
        if shouldSelectModel {
            presentNamedValuesViewController(brand: object)
        } else {
            delegate?.brandListViewController(self, didSelectBrand: object)
        }
    }
    
    // MARK: - Search Results Updating
    
    func updateSearchResults(for searchController: UISearchController) {
        searchTerm = searchController.searchBar.text
    }
    
    // MARK: - Model List Presenting
    
    private var brand: CarBrand?
    
    private func presentNamedValuesViewController(brand: CarBrand) {
        self.brand = brand
        let interactor = self.interactor.createModelsInteractor(brandId: brand.id)
        let viewController = GenericListViewController(interactor: interactor, configure: {
            $0.titleLabel?.text = $1.name
        }, select: { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.brandListViewController(self, didSelectBrand: brand, model: $0)
        })
        viewController.title = "Выбор модели"
        show(viewController, sender: nil)
    }
    
}
