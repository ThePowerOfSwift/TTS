//
//  GarageMainAutoInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 16/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class GarageMainAutoInteractor {
    
    private let autoId: String
    private let services: ServiceCentersService
    private let autos: UserAutoService
    private let orders: OrderService
    private let disposeBag = DisposeBag()
    
    init(autoId: String, services: ServiceCentersService, autos: UserAutoService, orders: OrderService) {
        self.autoId = autoId
        self.services = services
        self.autos = autos
        self.orders = orders
    }
    
    func observeAuto(onNext: @escaping (UserAuto?) -> Void) {
        autos.observe(id: autoId)
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: onNext)
            .disposed(by: disposeBag)
    }
    
    func createServiceCenterGroupTabsInteractor(serviceId: Int) -> ServiceCenterGroupTabsInteractor {
        return ServiceCenterGroupTabsInteractor(services: services, autos: autos, filter: .serviceId(serviceId))
    }
    
    func createOrderTechServiceAppointmentCancelInteractor(serviceCenter: ServiceCenter, record: TechServiceRecord) -> OrderTechServiceAppointmentCancelInteractor {
        return OrderTechServiceAppointmentCancelInteractor(orders: orders, autos: autos, autoId: autoId, serviceCenter: serviceCenter, record: record)
    }
    
}
