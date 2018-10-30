//
//  OrderTechServiceInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 29/05/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit

final class OrderTechServiceInteractor {
    
    private let orders: OrderService
    private let autos: UserAutoService
    private let auto: UserAuto
    private let serviceCenter: ServiceCenter
    
    init(orders: OrderService, autos: UserAutoService, auto: UserAuto, serviceCenter: ServiceCenter) {
        self.orders = orders
        self.autos = autos
        self.auto = auto
        self.serviceCenter = serviceCenter
    }
    
    func createOrderTechServiceMileageInteractor() -> OrderTechServiceMileageInteractor {
        return OrderTechServiceMileageInteractor(orders: orders, autoUid: auto.id)
    }
    
    func createOrderTechServiceProposeInteractor(list: OrderTechServiceGetListResponse) -> OrderTechServiceProposeInteractor {
        return OrderTechServiceProposeInteractor(orders: orders, autoUid: auto.id, serviceCenter: serviceCenter, list: list)
    }

    func createOrderTechServiceListInteractor(list: OrderTechServiceGetListResponse) -> OrderTechServiceListInteractor {
        return OrderTechServiceListInteractor(orders: orders, autoUid: auto.id, list: list)
    }
    
    func createOrderTechServiceDetailSelectInteractor(service: OrderTechServiceGetListResponse.Service, details: OrderTechServiceGetDetailResponse) -> OrderTechServiceDetailSelectInteractor {
        return OrderTechServiceDetailSelectInteractor(orders: orders, autoUid: auto.id, serviceCenterUid: service.uid, techService: service, details: details)
    }
    
    func createOrderTechServiceDetailInteractor(service: OrderTechServiceGetListResponse.Service, detail: OrderTechServiceGetDetailResponse.Detail) -> OrderTechServiceDetailInteractor {
        return OrderTechServiceDetailInteractor(techService: service, detail: detail)
    }
    
    func createOrderTechServiceVariantsInteractor(selection: OrderTechServiceSelection) -> OrderTechServiceVariantsInteractor {
        return OrderTechServiceVariantsInteractor(orders: orders, auto: auto, serviceCenter: serviceCenter, selection: selection)
    }
    
    func createOrderTechServiceAppointmentConfirmInteractor(selection: OrderTechServiceSelection, variant: OrderTechServiceGetVariantsResponse.Variant) -> OrderTechServiceAppointmentConfirmInteractor {
        return OrderTechServiceAppointmentConfirmInteractor(orders: orders, autos: autos, auto: auto, serviceCenter: serviceCenter, selection: selection, variant: variant)
    }
    
}
