//
//  GarageMainInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 02/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class GarageMainInteractor {
    
    private let user: UserInfoService
    private let autos: UserAutoService
    private let archive: ArchivedAutoService
    private let dictionaries: DictionariesService
    private let services: ServiceCentersService
    private let orders: OrderService
    private let repair: RepairService
    private let notifications: NotificationsManager
    private let disposeBag = DisposeBag()
    
    init(user: UserInfoService, autos: UserAutoService, archive: ArchivedAutoService, dictionaries: DictionariesService, services: ServiceCentersService, orders: OrderService, repair: RepairService, notifications: NotificationsManager) {
        self.user = user
        self.autos = autos
        self.archive = archive
        self.services = services
        self.dictionaries = dictionaries
        self.orders = orders
        self.repair = repair
        self.notifications = notifications
    }
    
    func observeData(onNext: @escaping (([UserInfo], [UserAuto])) -> Void) {
        Observable.combineLatest(user.observe().distinctUntilChanged(),
                                 autos.observeAllSortedByOrder().distinctUntilChanged())
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: onNext)
            .disposed(by: disposeBag)
    }
    
    func reloadData(completion: @escaping (Result<Bool>) -> Void) {
        Single.zip(user.pull(), autos.pull(), services.pull())
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: {
                let numberOfCharacters = $0.0.name?.count ?? 0
                let shouldSetupUserName = numberOfCharacters > 0
                completion(Result(value: shouldSetupUserName))
            }, onError: {
                completion(Result(error: $0))
            }).disposed(by: disposeBag)
    }
    
    func registerForRemoteNotifications() {
        // send firebase token to the server
        notifications.fetchFirebaseInstanceID()
            .flatMap { [user] in user.setPushToken(token: $0.token) }
            .subscribe()
            .disposed(by: disposeBag)
        
        // request authorization for alert/badge/sound messages
        notifications.requestAuthorization()
            .subscribe()
            .disposed(by: disposeBag)
        
        notifications.registerForRemoteNotifications()
    }
    
    func createGarageMainAutoInteractor(autoId: String) -> GarageMainAutoInteractor {
        return GarageMainAutoInteractor(autoId: autoId, services: services, autos: autos, orders: orders)
    }
    
    func createGarageAutoInfoInteractor(auto: UserAuto) -> GarageAutoInfoInteractor {
        return GarageAutoInfoInteractor(auto: auto, autos: autos, services: services, archive: archive)
    }
    
    func createAddCarInteractor() -> AddCarInteractor {
        return AddCarInteractor(autos: autos, services: services, dictionaries: dictionaries)
    }
    
    func createOrderTechServiceAction() -> OrderTechServiceAction {
        return OrderTechServiceAction(orders: orders, autos: autos)
    }
    
    func createOrderRepairInteractor(auto: UserAuto) -> OrderRepairInteractor {
        return OrderRepairInteractor(auto: auto, repair: repair)
    }
    
    func createAuthUserNameInteractor() -> AuthUserNameInteractor {
        return AuthUserNameInteractor(user: user)
    }

}
