//
//  HistoryTabsViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 29/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

final class HistoryTabsViewController: UIViewController, ErrorPresenting, DataReloading {

    private let interactor: HistoryTabsInteractor
    private let spinner = UIActivityIndicatorView(style: .white)
    
    init(interactor: HistoryTabsInteractor) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Navigation Interface
    
    override var navigationItem: UINavigationItem {
        let navigationItem = super.navigationItem
        navigationItem.title = "История обслуживания"
        return navigationItem
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 37, g: 42, b: 57)
        
        updateChildViewControllers()

        interactor.observeAutos { [weak self] in
            self?.autos = $0
        }
        
        reloadData()
    }
    
    // MARK: - Reloading Data
    
    func reloadData() {
        setIsLoading(true)
        interactor.reloadData { [weak self] in
            self?.setIsLoading(false)
            if let error = $0 {
                self?.showError(error)
            }
        }
    }
    
    private var isLoading = false
    private func setIsLoading(_ loading: Bool) {
        guard isLoading != loading else { return }
        isLoading = loading

        if loading, (autos?.count ?? 0) == 0 {
            removeHistoryEmptyViewController()
            removeHistoryTreatmentsViewControllers()
            
            spinner.center = view.bounds.center
            spinner.autoresizingMask = .flexibleMargins
            view.addSubview(spinner)
            spinner.startAnimating()
        } else {
            if spinner.superview != nil {
                updateChildViewControllers()
            }
            spinner.removeFromSuperview()
        }
        
        for viewController in tabLayoutViewController?.children ?? [] {
            (viewController as? HistoryTreatmentsViewController)?.setIsLoading(loading)
        }
    }
    
    // MARK: - Child Controllers
    
    private var autos: [UserAuto]? {
        didSet {
            guard !isLoading else { return }
            updateChildViewControllers()
        }
    }
    
    private func updateChildViewControllers() {
        if let autos = autos, autos.count > 0 {
            removeHistoryEmptyViewController()
            setHistoryTreatmentsViewControllers(autos: autos)
        } else {
            removeHistoryTreatmentsViewControllers()
            addHistoryEmptyViewController()
        }
    }
    
    private var historyEmptyViewController: HistoryEmptyViewController?

    private func addHistoryEmptyViewController() {
        if historyEmptyViewController == nil {
            historyEmptyViewController = HistoryEmptyViewController(auto: nil)
        }

        let viewController = historyEmptyViewController!
        if viewController.parent != self {
            addChild(viewController)
            viewController.view.frame = view.bounds
            view.addSubview(viewController.view)
            viewController.didMove(toParent: self)
        }
    }

    private func removeHistoryEmptyViewController() {
        guard let viewController = historyEmptyViewController else { return }

        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
        historyEmptyViewController = nil
    }

    private var tabLayoutViewController: TabLayoutViewController?

    private func setHistoryTreatmentsViewControllers(autos: [UserAuto]) {
        if tabLayoutViewController != nil {
            removeHistoryTreatmentsViewControllers()
        }

        if #available(iOS 11, *) {
            // do nothing
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        let viewControllers = autos.map { HistoryTreatmentsViewController(auto: $0, interactor: interactor.createHistoryTreatmentsInteractor()) }
        
        let viewController = TabLayoutViewController(viewControllersForPagerTabStripController: viewControllers, didChangeCurrentIndex: { [weak self] in
            self?.tabLayoutViewControllerDidChangeCurrentIndex($0)
        })
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

    private func removeHistoryTreatmentsViewControllers() {
        guard let viewController = tabLayoutViewController else { return }

        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
        tabLayoutViewController = nil
        
        if #available(iOS 11, *) {
            // do nothing
        } else {
            automaticallyAdjustsScrollViewInsets = true
        }
    }

    private func tabLayoutViewControllerDidChangeCurrentIndex(_ currentIndex: Int) {
        // do nothing
    }
    
}
