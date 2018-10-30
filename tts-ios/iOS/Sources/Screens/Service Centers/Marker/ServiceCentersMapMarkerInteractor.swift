//
//  ServiceCentersMapMarkerInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 20/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class ServiceCentersMapMarkerInteractor {
    
    private let services: ServiceCentersService
    private let autos: UserAutoService
    private var disposable: Disposable?
    
    deinit {
        disposable?.dispose()
    }
    
    init(services: ServiceCentersService, autos: UserAutoService) {
        self.services = services
        self.autos = autos
    }
    
    func observe(latitude: String, longitude: String, onNext: ((ServiceCenterGroup?) -> Void)?) {
        disposable = services.observe(latitude: latitude, longitude: longitude)
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: onNext)
    }
    
    func createServiceCenterGroupTabsInteractor(latitude: String, longitude: String) -> ServiceCenterGroupTabsInteractor {
        return ServiceCenterGroupTabsInteractor(services: services, autos: autos, filter: .location(latitude: latitude, longitude: longitude))
    }
    
}
