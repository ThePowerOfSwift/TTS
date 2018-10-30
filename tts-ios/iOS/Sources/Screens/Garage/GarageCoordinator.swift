//
//  GarageCoordinator.swift
//  tts
//
//  Created by Dmitry Nesterenko on 29/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit

final class GarageCoordinator: Coordinator {
    
    class TabBarControllerDelegate: NSObject, UITabBarControllerDelegate {
        
        var didSelect: ((UIViewController) -> Void)?
        
        func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
            self.didSelect?(viewController)
        }
        
    }
    
    private let tabBarController: UITabBarController!
    private let tabBarControllerDelegate: TabBarControllerDelegate // swiftlint:disable:this weak_delegate
    private let auth: AuthService
    private let user: UserInfoService
    private let autos: UserAutoService
    private let treatment: TreatmentService
    private let treatmentDetail: TreatmentDetailService
    private let archive: ArchivedAutoService
    private let dictionaries: DictionariesService
    private let serviceCenters: ServiceCentersService
    private let orders: OrderService
    private let repair: RepairService
    private let notifications: NotificationsManager
    private let completion: () -> Void
    
    init(auth: AuthService, user: UserInfoService, autos: UserAutoService, treatment: TreatmentService, treatmentDetail: TreatmentDetailService, archive: ArchivedAutoService, dictionaries: DictionariesService, serviceCenters: ServiceCentersService, orders: OrderService, repair: RepairService, notifications: NotificationsManager, completion: @escaping () -> Void) {
        self.auth = auth
        self.user = user
        self.autos = autos
        self.treatment = treatment
        self.treatmentDetail = treatmentDetail
        self.archive = archive
        self.dictionaries = dictionaries
        self.serviceCenters = serviceCenters
        self.orders = orders
        self.repair = repair
        self.notifications = notifications
        self.completion = completion
        tabBarController = UITabBarController()
        tabBarControllerDelegate = TabBarControllerDelegate()
        tabBarController.delegate = tabBarControllerDelegate
        
        super.init()
        
        tabBarControllerDelegate.didSelect = { [unowned self] in
            self.tabBarControllerDidSelectViewController($0)
        }
    }
    
    func instantiateInitialViewController() -> UITabBarController {
        var viewControllers = [UIViewController]()
        let barTintColor = UIColor(r: 19, g: 25, b: 43)
        let tintColor = UIColor.white
        let barStyle = UIBarStyle.black
        let call = CallAction(presentingViewController: tabBarController, user: user)
        
        // garage
        do {
            let interactor = GarageMainInteractor(user: user, autos: autos, archive: archive, dictionaries: dictionaries, services: serviceCenters, orders: orders, repair: repair, notifications: notifications)
            let viewController = GarageMainTabsViewController(interactor: interactor, call: call)
            let navigationController = NavigationController(style: .transparent, tintColor: tintColor, barStyle: barStyle)
            navigationController.viewControllers = [viewController]
            navigationController.tabBarItem.title = "Мой гараж"
            navigationController.tabBarItem.image = #imageLiteral(resourceName: "icn_global_garage")
            viewControllers.append(navigationController)
        }
        
        // history
        do {
            let interactor = HistoryTabsInteractor(treatment: treatment, treatmentDetail: treatmentDetail, autos: autos)
            let viewController = HistoryTabsViewController(interactor: interactor)
            let navigationController = NavigationController(style: .barTintColor(barTintColor), tintColor: tintColor, barStyle: barStyle)
            navigationController.viewControllers = [viewController]
            navigationController.tabBarItem.title = "История"
            navigationController.tabBarItem.image = #imageLiteral(resourceName: "icn_global_history")
            viewControllers.append(navigationController)
        }
        
        // services
        do {
            let filter = ServiceCentersFilterAction(presentingViewController: tabBarController, interactor: ServiceCentersFilterInteractor(dictionaries: dictionaries))
            let interactor = ServiceCentersTabsInteractor(services: serviceCenters, autos: autos)
            let viewController = ServiceCentersTabsViewController(interactor: interactor, call: call, filter: filter)
            let navigationController = NavigationController(style: .transparent, tintColor: tintColor, barStyle: barStyle)
            navigationController.viewControllers = [viewController]
            navigationController.tabBarItem.title = "Сервисы"
            navigationController.tabBarItem.image = #imageLiteral(resourceName: "icn_global_pin")
            viewControllers.append(navigationController)
        }
        
        // profile
        do {
            var coordinator: ProfileCoordinator?
            coordinator = ProfileCoordinator(auth: auth, user: user, autos: autos, services: serviceCenters, archive: archive, dictionaries: dictionaries, loggedOut: { [weak self, weak coordinator] in
                if let coordinator = coordinator {
                    self?.remove(coordinator)
                }
                self?.completion()
            })
            coordinator?.navigationController.tabBarItem.title = "Профиль"
            coordinator?.navigationController.tabBarItem.image = #imageLiteral(resourceName: "icn_global_profile")
            viewControllers.append(coordinator!.navigationController)
            add(coordinator!)
        }
        
        tabBarController.tabBar.isTranslucent = true
        tabBarController.tabBar.tintColor = UIColor(r: 241, g: 52, b: 52)
        tabBarController.tabBar.barTintColor = barTintColor
        tabBarController.viewControllers = viewControllers
        
        return tabBarController
    }
    
    // MARK: - Tab Bar Controller
    
    private func tabBarControllerDidSelectViewController(_ viewController: UIViewController) {
        guard let navigationController = viewController as? UINavigationController else { return }
        guard let topViewController = navigationController.topViewController, topViewController.isViewLoaded else { return }
        guard let viewController = topViewController as? DataReloading else { return }
        viewController.reloadData()
    }
    
}

extension UITabBarController: ErrorPresenting {}
