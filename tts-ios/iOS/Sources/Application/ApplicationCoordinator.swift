//
//  ApplicationCoordinator.swift
//  tts
//
//  Created by Dmitry Nesterenko on 25/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import RxSwift

final class ApplicationCoordinator: Coordinator {

    private let window: UIWindow
    private let client: TTSClient
    private let sessionStorage: SessionStorage
    private let auth: AuthService
    private let user: UserInfoService
    private let autos: UserAutoService
    private let archive: ArchivedAutoService
    private let treatment: TreatmentService
    private let treatmentDetail: TreatmentDetailService
    private let dictionaries: DictionariesService
    private let serviceCenters: ServiceCentersService
    private let orders: OrderService
    private let repair: RepairService
    private let notifications: NotificationsManager
    private let disposeBag = DisposeBag()
    
    private weak var onboardingCoordinator: OnboardingCoordinator?
    private weak var authCoordinator: AuthCoordinator?
    private weak var garageCoordinator: GarageCoordinator?
    
    init(window: UIWindow, notifications: NotificationsManager) {
        self.window = window
        sessionStorage = SessionStorage(keychain: Keychain.default)
        client = TTSClient(sessionStorage: sessionStorage)
        
        NetworkActivityIndicatorManager.shared.isEnabled = true
        
        let url = Bundle(for: TTSClient.self).url(forResource: "Model", withExtension: "momd")!
        let connector = PersistentConnector(url: url)!
        _ = connector.connect().subscribe()
        
        let logger = Logger(subsystem: "", category: "repository")
        auth = AuthService(client: client, sessionStorage: sessionStorage, connector: connector)
        user = UserInfoService(client: client, repository: UserInfoRepository(connector: connector, logger: logger))
        autos = UserAutoService(client: client, repository: UserAutoRepository(connector: connector, logger: logger))
        archive = ArchivedAutoService(client: client, repository: ArchivedAutoRepository(connector: connector, logger: logger))
        treatment = TreatmentService(client: client, repository: TreatmentRepository(connector: connector, logger: logger))
        treatmentDetail = TreatmentDetailService(client: client, repository: TreatmentDetailRepository(connector: connector, logger: logger))
        serviceCenters = ServiceCentersService(client: client, repository: ServiceCentersRepository(connector: connector, logger: logger))
        orders = OrderService(client: client)
        dictionaries = DictionariesService(client: client)
        repair = RepairService(client: client)
        self.notifications = notifications
        
        KeyboardObserver.shared.isTracking = true
        
        super.init()
        
        client.invalidAccessTokenHandler = { [unowned self] completion in
            DispatchQueue.main.async {
                self.transitionFromGarageToAuthCoordinator(completion: { _ in
                    self.auth.logout()
                        .observeOn(MainScheduler.instance)
                        .subscribe(onCompleted: {
                            completion()
                        }, onError: { _ in
                            completion()
                        }).disposed(by: self.disposeBag)
                })
            }
        }
    }
    
    func launch() -> Bool {
        let versionTracker = BundleVersionTracker()
        
        if versionTracker.type == .firstRun {
            window.rootViewController = instantiateOnboardingCoordinator {
                versionTracker.saveCurrentBundleVersion()
            }
        } else {
            if let _ = try? sessionStorage.credential() { // swiftlint:disable:this unused_optional_binding
                window.rootViewController = instantiateGarageCoordinator()
            } else {
                window.rootViewController = instantiateAuthCoordinator()
            }
        }

        window.makeKeyAndVisible()
        
        return true
    }
    
    private func instantiateOnboardingCoordinator(completion: @escaping () -> Void) -> UIViewController {
        let coordinator = OnboardingCoordinator { [weak self] in
            self?.transitionFromOnboardingToAuthCoordinator()
            completion()
        }
        
        add(coordinator)
        onboardingCoordinator = coordinator
        
        return coordinator.instantiateInitialViewController()
    }
    
    private func instantiateAuthCoordinator() -> UIViewController {
        let coordinator = AuthCoordinator(auth: auth, user: user, completion: { [weak self] in
            self?.transitionFromAuthToGarageCoordinator()
        })

        add(coordinator)
        authCoordinator = coordinator
        
        return coordinator.instantiateInitialViewController()
    }
    
    private func instantiateGarageCoordinator() -> UIViewController {
        let coordinator = GarageCoordinator(auth: auth, user: user, autos: autos, treatment: treatment, treatmentDetail: treatmentDetail, archive: archive, dictionaries: dictionaries, serviceCenters: serviceCenters, orders: orders, repair: repair, notifications: notifications, completion: { [weak self] in
            self?.transitionFromGarageToAuthCoordinator(completion: nil)
        })

        add(coordinator)
        garageCoordinator = coordinator
        
        return coordinator.instantiateInitialViewController()
    }
    
    private func transitionFromOnboardingToAuthCoordinator() {
        guard let coordinator = onboardingCoordinator else { return }
        let viewController = instantiateAuthCoordinator()
        window.replaceRootViewController(with: viewController, animation: .crossDissolve)
        remove(coordinator)
    }
    
    private func transitionFromAuthToGarageCoordinator() {
        guard let coordinator = authCoordinator else { return }
        let viewController = instantiateGarageCoordinator()
        window.replaceRootViewController(with: viewController, animation: .flipFromRight)
        remove(coordinator)
    }
    
    private func transitionFromGarageToAuthCoordinator(completion: ((Bool) -> Void)?) {
        guard let coordinator = garageCoordinator else { return }
        let viewController = instantiateAuthCoordinator()
        window.replaceRootViewController(with: viewController, animation: .flipFromLeft, completion: completion)
        remove(coordinator)
    }
    
}
