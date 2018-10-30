//
//  ServiceCentersTabsViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 29/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

final class ServiceCentersTabsViewController: UIViewController, ErrorPresenting, DataReloading, ServiceCentersFilterable {
    
    private let interactor: ServiceCentersTabsInteractor
    private let call: CallAction
    private let filter: ServiceCentersFilterAction
    private let filterButton = UIButton(type: .system)
    
    init(interactor: ServiceCentersTabsInteractor, call: CallAction, filter: ServiceCentersFilterAction) {
        self.interactor = interactor
        self.call = call
        self.filter = filter
        super.init(nibName: nil, bundle: nil)

        filterButton.setImage(#imageLiteral(resourceName: "icn_global_filter"), for: .normal)
        filterButton.sizeToFit()
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)

        navigationItem.title = "Сервисные центры"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Navigation Interface
    
    override var navigationItem: UINavigationItem {
        let navigationItem = super.navigationItem
        if navigationItem.rightBarButtonItem == nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: filterButton)
        }
        return navigationItem
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTabViewControllers()
    }
    
    private var tabLayoutViewController: TabLayoutViewController?
    
    private func loadTabViewControllers() {
        guard tabLayoutViewController == nil else { return }
        
        if #available(iOS 11, *) {
            // do nothing
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        let mapViewController = ServiceCentersMapViewController(interactor: interactor.createServiceCentersMapInteractor(), call: call)
        let listInteractor = interactor.createServiceCentersListInteractor(location: mapViewController.myLocationObservable())
        let viewControllers = [mapViewController, ServiceCentersListViewController(interactor: listInteractor)]
        let viewController = TabLayoutViewController(viewControllersForPagerTabStripController: viewControllers, didChangeCurrentIndex: nil)
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: 0).isActive = true
        topLayoutGuide.bottomAnchor.constraint(equalTo: viewController.view.topAnchor, constant: 0).isActive = true
        bottomLayoutGuide.topAnchor.constraint(equalTo: viewController.view.bottomAnchor, constant: 0).isActive = true
        viewController.didMove(toParent: self)
        
        tabLayoutViewController = viewController
    }
    
    // MARK: - Data Reloading
    
    func reloadData() {
        interactor.loadData(completion: { [weak self] in
            if let error = $0 {
                self?.showError(error)
            }
        })
    }
    
    // MARK: - Filtering Results
    
    private var brand: CarBrand?
    private var city: NamedValue?
    
    @objc
    private func filterButtonTapped() {
        filter.presentInitialViewController(brand: brand, city: city, update: { [weak self] in
            self?.applyFilter(brand: $0, city: $1)
        }, cancel: {
            // do nothing
        })
    }
    
    func applyFilter(brand: CarBrand?, city: NamedValue?) {
        self.brand = brand
        self.city = city
        
        let selected = brand != nil || city != nil
        filterButton.isSelected = selected
        
        tabLayoutViewController?.viewControllers.forEach {
            if let filterable = $0 as? ServiceCentersFilterable {
                filterable.applyFilter(brand: brand, city: city)
            }
        }
    }
    
}
