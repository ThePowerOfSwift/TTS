//
//  ServiceCentersMapInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 26/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class ServiceCentersMapInteractor {
    
    private let services: ServiceCentersService
    private let autos: UserAutoService
    private let disposeBag = DisposeBag()
    
    deinit {
        observer?.dispose()
    }
    
    init(services: ServiceCentersService, autos: UserAutoService) {
        self.services = services
        self.autos = autos
    }
    
    var observer: Disposable?
    
    func observeData(brand: CarBrand?, city: NamedValue?, onNext: @escaping ([ServiceCenterGroup]) -> Void) {
        observer?.dispose()
        observer = services.observeAllSortedByOrder()
            .map { $0.filter(brand: brand, city: city) }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: onNext)
    }
    
    func createServiceCentersMapMarkerInteractor() -> ServiceCentersMapMarkerInteractor {
        return ServiceCentersMapMarkerInteractor(services: services, autos: autos)
    }
        
}
