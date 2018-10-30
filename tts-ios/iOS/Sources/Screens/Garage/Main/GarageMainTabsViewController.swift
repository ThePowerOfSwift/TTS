//
//  GarageMainTabsViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 29/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import IGListKit
import AlamofireImage
import SwiftMessages

final class GarageMainTabsViewController: UIViewController, ErrorPresenting, DataReloading, GarageMainEmptyViewControllerDelegate {

    private let interactor: GarageMainInteractor
    private let bonusesButton = UIButton(type: .system)
    private let spinner = UIActivityIndicatorView(style: .white)
    private let call: CallAction
    private let orderTechService: OrderTechServiceAction
    
    init(interactor: GarageMainInteractor, call: CallAction) {
        self.interactor = interactor
        self.call = call
        self.orderTechService = interactor.createOrderTechServiceAction()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Navigation Interface
    
    private func setBrandImage(_ url: URL?) {
        if let url = url {
            let button = UIButton(type: .system)
            button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
            button.af_setImage(for: .normal, url: url, filter: AspectScaledToFitSizeFilter(size: button.frame.size), completion: { [weak button] response in
                if let image = response.result.value {
                    button?.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
                }
            })
            button.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "title_logo"))
        view.backgroundColor = UIColor(r: 25, g: 27, b: 32)
        
        setBrandImage(nil)
        
        bonusesButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        bonusesButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 15)
        bonusesButton.titleEdgeInsets = UIEdgeInsets(top: 1, left: 10, bottom: -1, right: -10)
        bonusesButton.setImage(#imageLiteral(resourceName: "icn_global_star"), for: .normal)
        bonusesButton.isUserInteractionEnabled = false
        
        reloadData()
        
        interactor.registerForRemoteNotifications()
        
        interactor.observeData { [weak self] in
            self?.userInfo = $0.0.first
            self?.autos = $0.1
            self?.updateChildViewControllers()
        }
    }
    
    // MARK: - Responding to View Events
    
    private var viewHasBeenAppeared = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewHasBeenAppeared = true
        presentUserNameViewControllerIfNeeded()
    }
    
    // MARK: - Displaying User Name Screen
    
    private var userNameViewControllerDidAppear = false
    
    private func presentUserNameViewControllerIfNeeded() {
        let isUserNameEmpty = userInfo.flatMap { ($0.name?.count ?? 0) == 0 } ?? false
        guard viewHasBeenAppeared, !userNameViewControllerDidAppear, isUserNameEmpty else { return }
        presentUserNameViewController(completion: nil)
        userNameViewControllerDidAppear = true
    }
    
    // MARK: - Presenting User Name View Controller
    
    /// - parameters:
    ///     - completion: Called after view controller did set first and last name and did dismiss.
    private func presentUserNameViewController(completion: (() -> Void)?) {
        let interactor = self.interactor.createAuthUserNameInteractor()
        let viewController = AuthUserNameViewController(interactor: interactor, completion: { [weak self] in
            self?.dismiss(animated: IsAnimationAllowed(), completion: completion)
        })
        let navigationController = NavigationController(style: .barTintColor(UIColor(r: 19, g: 25, b: 43)), tintColor: .white, barStyle: .black)
        navigationController.viewControllers = [viewController]
        present(navigationController, animated: IsAnimationAllowed())
    }
    
    // MARK: - Reloading Data
    
    func reloadData() {
        if (autos?.count ?? 0) == 0 {
            setIsLoading(true)
        }
        
        interactor.reloadData { [weak self] in
            self?.setIsLoading(false)
            switch $0 {
            case .success(let shouldSetupUserName):
                if shouldSetupUserName {
                    self?.presentUserNameViewControllerIfNeeded()
                }
            case .failure(let error):
                self?.showError(error)
            }
        }
    }
    
    private var isLoading = false
    private func setIsLoading(_ loading: Bool) {
        if loading {
            removeGarageEmptyViewController()
            removeGarageAutosViewControllers()
            
            spinner.center = view.bounds.center
            spinner.autoresizingMask = .flexibleMargins
            view.addSubview(spinner)
            spinner.startAnimating()
        } else {
            spinner.removeFromSuperview()
        }
        isLoading = loading
        
        if children.count == 0 {
            updateChildViewControllers()
        }
    }
    
    // MARK: - User Info
    
    private var userInfo: UserInfo? {
        didSet {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            UIView.performWithoutAnimation {
                bonusesButton.setTitle(formatter.string(from: userInfo?.bonuses ?? 0), for: .normal)
                bonusesButton.sizeToFit()
                navigationItem.leftBarButtonItem = UIBarButtonItem(customView: bonusesButton)
            }
        }
    }
    
    // MARK: - Autos
    
    private var autos: [UserAuto]?
    
    private func updateChildViewControllers() {
        if isLoading, (autos?.count ?? 0) == 0 {
            removeGarageEmptyViewController()
            removeGarageAutosViewControllers()
            return
        }
        
        if let autos = autos, autos.count > 0 {
            removeGarageEmptyViewController()
            setGarageAutosViewControllers(autos: autos)
        } else {
            removeGarageAutosViewControllers()
            addGarageEmptyViewController()
            setBrandImage(nil)
        }
    }

    private var garageEmptyViewController: GarageMainEmptyViewController?

    private func addGarageEmptyViewController() {
        if garageEmptyViewController == nil {
            garageEmptyViewController = GarageMainEmptyViewController(call: call)
            garageEmptyViewController?.delegate = self
        }
        
        let viewController = garageEmptyViewController!
        if viewController.parent != self {
            addChild(viewController)
            viewController.view.frame = view.bounds
            view.addSubview(viewController.view)
            viewController.didMove(toParent: self)
        }
    }
    
    private func removeGarageEmptyViewController() {
        guard let viewController = garageEmptyViewController else { return }

        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
        garageEmptyViewController = nil
    }
    
    private var tabLayoutViewController: TabLayoutViewController?

    private func setGarageAutosViewControllers(autos: [UserAuto]) {
        if #available(iOS 11, *) {
            // do nothing
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        // save last selected index and view controller
        let currentChildViewControllers = tabLayoutViewController?.viewControllers as? [GarageMainAutoViewController] ?? []
        var currentChildViewController: GarageMainAutoViewController?
        let lastCurrentIndex = tabLayoutViewController?.currentIndex ?? 0
        if lastCurrentIndex < currentChildViewControllers.count {
            currentChildViewController = currentChildViewControllers[lastCurrentIndex]
        }
        
        let viewControllers: [GarageMainAutoViewController] = autos.map { auto in
            if let viewController = currentChildViewControllers.first(where: { $0.auto?.id == auto.id }) {
                return viewController
            } else {
                return GarageMainAutoViewController(title: auto.brand, interactor: interactor.createGarageMainAutoInteractor(autoId: auto.id), call: call, onService: { [weak self] in
                    self?.presentOrderTechService(auto: $0)
                    }, onRepair: { [weak self] in
                        self?.presentOrderRepairViewController(auto: $0)
                    }, onPrice: { [weak self] _ in
                        self?.presentUnderConstructionMessage()
                })
            }
        }
        
        // calculate new current index
        let currentIndex: Int
        if let currentChildViewController = currentChildViewController {
            if let index = viewControllers.index(of: currentChildViewController) {
                currentIndex = index
            } else {
                currentIndex = max(0, lastCurrentIndex - 1)
            }
        } else {
            currentIndex = 0
        }
        
        removeGarageAutosViewControllers()

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
        viewController.updateIfNeeded()
        viewController.moveToViewController(at: currentIndex, animated: false)
        tabLayoutViewControllerDidChangeCurrentIndex(currentIndex)
    }
    
    private func removeGarageAutosViewControllers() {
        guard let viewController = tabLayoutViewController else { return }
        
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
        tabLayoutViewController = nil
        
        if #available(iOS 11, *) {
            // do nothing
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    private func tabLayoutViewControllerDidChangeCurrentIndex(_ currentIndex: Int) {
        guard let auto = autos?[currentIndex] else { return }
        setBrandImage(auto.brandImage)
    }
    
    // MARK: - Actions
    
    @objc
    private func infoButtonTapped() {
        guard let index = tabLayoutViewController?.currentIndex, let auto = autos?[index] else { return }
        let viewController = GarageAutoInfoViewController(interactor: interactor.createGarageAutoInfoInteractor(auto: auto), archived: { [weak self] in
            self?.dismiss(animated: IsAnimationAllowed(), completion: nil)
        })
        present(viewController, animated: IsAnimationAllowed(), completion: nil)
    }
    
    // MARK: - Garage Empty View Controller
    
    func garageMainEmptyViewControllerDidTapAddCarButton(_ viewController: GarageMainEmptyViewController) {
        presentAddCarViewController()
    }
    
    // MARK: - Add Car
    
    private func presentAddCarViewController() {
        presentUnderConstructionMessage()

//        let interactor = self.interactor.createAddCarInteractor()
//        let viewController = AddCarNavigationViewController(interactor: interactor, success: { [weak self] in
//            self?.presentSuccessMessage(config: $0, view: $1)
//        })
//        present(viewController, animated: IsAnimationAllowed(), completion: nil)
    }

    // MARK: - Presenting Success Message
    
    private func presentSuccessMessage(config: SwiftMessages.Config, view: MessageView) {
        view.statusBarOffset = UIApplication.shared.statusBarFrame.height
        view.safeAreaTopOffset = UIApplication.shared.statusBarFrame.height + 44
        SwiftMessages.show(config: config, view: view)
    }
    
    // MARK: - Presenting Order Tech Service
    
    private func presentOrderTechService(auto: UserAuto) {
        if let service = auto.serviceCenter {
            orderTechService.run(presentingViewController: self, auto: auto, service: service, completion: nil)
        } else {
            showError(title: "Автомобиль не привязан к сервисному центру", message: nil, animated: IsAnimationAllowed())
        }
    }
    
    // MARK: - Presenting Under Construction Message
    
    private func presentUnderConstructionMessage() {
        showError(title: "Раздел находится в разработке", message: nil, animated: IsAnimationAllowed())
    }
    
    // MARK: - Presenting Order Repair View Controller
    
    private func presentOrderRepairViewController(auto: UserAuto) {
        let interactor = self.interactor.createOrderRepairInteractor(auto: auto)
        let navigationController = OrderRepairNavigationController(interactor: interactor) {
            $0.dismiss(animated: IsAnimationAllowed())
        }
        present(navigationController, animated: IsAnimationAllowed())
    }
    
}
