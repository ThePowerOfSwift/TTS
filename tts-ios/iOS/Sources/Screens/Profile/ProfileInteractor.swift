//
//  ProfileInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 31/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift
import UserNotifications

final class ProfileInteractor {
    
    private let auth: AuthService
    private let user: UserInfoService
    private let autos: UserAutoService
    private let services: ServiceCentersService
    private let archive: ArchivedAutoService
    private let dictionaries: DictionariesService
    private let disponseBag = DisposeBag()
    
    init(auth: AuthService, user: UserInfoService, autos: UserAutoService, services: ServiceCentersService, archive: ArchivedAutoService, dictionaries: DictionariesService) {
        self.auth = auth
        self.user = user
        self.autos = autos
        self.services = services
        self.archive = archive
        self.dictionaries = dictionaries
    }
    
    func observeUserInfo(onNext: @escaping ((UserInfo?, Bool)) -> Void) {
        let userInfo = user.observe()
            .map {$0.first}
            .distinctUntilChanged()
        
        let isPushAuthorized = NotificationSettingsObservable()
            .map { $0.authorizationStatus == .authorized }
            .distinctUntilChanged()
        
        Observable.combineLatest(userInfo, isPushAuthorized)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: onNext)
            .disposed(by: disponseBag)
    }
    
    func reloadUserInfo(completion: ((Error?) -> Void)? = nil) {
        user.pull()
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { _ in
                completion?(nil)
            }, onError: {
                completion?($0)
            }).disposed(by: disponseBag)
    }
    
    func logout(completion: @escaping (Error?) -> Void) {
        auth.logout()
            .observeOn(MainScheduler.instance)
            .subscribe(onCompleted: {
                completion(nil)
            }, onError: {
                completion($0)
            }).disposed(by: disponseBag)
    }
    
    func createGarageArchiveInteractor() -> GarageArchiveInteractor {
        return GarageArchiveInteractor(autos: autos, services: services, archive: archive)
    }
    
    func createAddCarInteractor() -> AddCarInteractor {
        return AddCarInteractor(autos: autos, services: services, dictionaries: dictionaries)
    }
    
    func setPushNotificationsEnabled(_ enabled: Bool, completion: @escaping (Result<UserInfo>) -> Void) {
        user.setPushNotify(enabled: enabled)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: {
                completion(Result(value: $0))
            }, onError: {
                completion(Result(error: $0))
            }).disposed(by: disponseBag)
    }
}
