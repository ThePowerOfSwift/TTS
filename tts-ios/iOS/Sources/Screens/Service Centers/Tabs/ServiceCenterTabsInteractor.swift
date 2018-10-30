//
//  ServiceCenterTabsInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 26/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift
    
final class ServiceCentersTabsInteractor {
    
    private let services: ServiceCentersService
    private let autos: UserAutoService
    private let disposeBag = DisposeBag()
    
    init(services: ServiceCentersService, autos: UserAutoService) {
        self.services = services
        self.autos = autos
    }
    
    func loadData(completion: ((Error?) -> Void)?) {
        services.pull()
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { _ in
                completion?(nil)
            }, onError: {
                completion?($0)
            }).disposed(by: disposeBag)
    }
    
    func createServiceCentersMapInteractor() -> ServiceCentersMapInteractor {
        return ServiceCentersMapInteractor(services: services, autos: autos)
    }
    
    func createServiceCentersListInteractor(location: Observable<CLLocation?>) -> ServiceCentersListInteractor {
        return ServiceCentersListInteractor(services: services, autos: autos, location: location)
    }
    
}
