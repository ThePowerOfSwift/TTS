//
//  ProfileCoordinator.swift
//  tts
//
//  Created by Dmitry Nesterenko on 12/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import SwiftMessages

private let kNavigationBarTintColorLight = UIColor(r: 19, g: 25, b: 43)
private let kNavigationBarTintColorDark = UIColor(r: 7, g: 9, b: 16)

class ProfileCoordinator: Coordinator, ProfileViewControllerDelegate {
    
    let navigationController: NavigationController
    private let auth: AuthService
    private let user: UserInfoService
    private let autos: UserAutoService
    private let services: ServiceCentersService
    private let archive: ArchivedAutoService
    private let dictionaries: DictionariesService
    private let interactor: ProfileInteractor
    
    init(auth: AuthService, user: UserInfoService, autos: UserAutoService, services: ServiceCentersService, archive: ArchivedAutoService, dictionaries: DictionariesService, loggedOut: @escaping () -> Void) {
        self.auth = auth
        self.user = user
        self.autos = autos
        self.services = services
        self.archive = archive
        self.dictionaries = dictionaries
        
        navigationController = NavigationController(style: .barTintColor(kNavigationBarTintColorLight), tintColor: .white, barStyle: .black)
        interactor = ProfileInteractor(auth: auth, user: user, autos: autos, services: services, archive: archive, dictionaries: dictionaries)
        
        super.init()
        
        let viewController = ProfileViewController(interactor: interactor, loggedOut: loggedOut)
        viewController.delegate = self
        navigationController.viewControllers = [viewController]
        navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Archive
    
    private func presentArchiveViewController() {
        let viewController = GarageArchiveViewController(interactor: interactor.createGarageArchiveInteractor())
        navigationController.show(viewController, sender: nil)

        (navigationController.navigationBar as? NavigationBar)?.style = .barTintColor(kNavigationBarTintColorLight)
        navigationController.setNavigationBarHidden(false, animated: IsAnimationAllowed())
    }
    
    func profileViewControllerDidTapArchiveCell(_ viewController: ProfileViewController) {
        presentArchiveViewController()
    }
    
    // MARK: - About

    private func presentAboutViewController() {
        let viewController = AboutViewController()
        navigationController.show(viewController, sender: nil)

        (navigationController.navigationBar as? NavigationBar)?.style = .barTintColor(kNavigationBarTintColorDark)
        navigationController.setNavigationBarHidden(false, animated: IsAnimationAllowed())
    }
    
    func profileViewControllerDidTapAboutCell(_ viewController: ProfileViewController) {
        presentAboutViewController()
    }

    // MARK: - Bonus

    private func presentBonusViewController() {
        let viewController = BonusViewController()
        navigationController.show(viewController, sender: nil)

        (navigationController.navigationBar as? NavigationBar)?.style = .barTintColor(kNavigationBarTintColorLight)
        navigationController.setNavigationBarHidden(false, animated: IsAnimationAllowed())
    }
    
    func profileViewControllerDidTapBonusButton(_ viewController: ProfileViewController) {
        presentBonusViewController()
    }

    // MARK: - Add Car

    private func presentAddCarViewController(close: (() -> Void)?) {
        let viewController = UIAlertController(title: "Раздел находится в разработке", message: nil, preferredStyle: .alert)
        viewController.addAction(UIAlertAction(title: "Закрыть", style: .default, handler: { _ in
            close?()
        }))
        navigationController.present(viewController, animated: IsAnimationAllowed())
        
//        let interactor = self.interactor.createAddCarInteractor()
//        let viewController = AddCarNavigationViewController(interactor: interactor, success: { [weak self] in
//            self?.presentSuccessMessage(config: $0, view: $1)
//        })
//        navigationController.present(viewController, animated: IsAnimationAllowed(), completion: nil)
    }
    
    func profileViewControllerDidTapAddCarCell(_ viewController: ProfileViewController, close: (() -> Void)?) {
        presentAddCarViewController(close: close)
    }
    
    // MARK: - Presenting Success Message
    
    private func presentSuccessMessage(config: SwiftMessages.Config, view: MessageView) {
        view.statusBarOffset = UIApplication.shared.statusBarFrame.height
        view.safeAreaTopOffset = UIApplication.shared.statusBarFrame.height + 44
        SwiftMessages.show(config: config, view: view)
    }
    
}
