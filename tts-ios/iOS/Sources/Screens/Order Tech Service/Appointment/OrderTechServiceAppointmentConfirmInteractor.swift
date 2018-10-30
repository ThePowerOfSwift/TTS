//
//  OrderTechServiceAppointmentConfirmInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class OrderTechServiceAppointmentConfirmInteractor: OrderTechServiceAppointmentInteractorInput {
    
    enum Error: LocalizedError {
        case sendOrderFailed
        
        var errorDescription: String? {
            switch self {
            case .sendOrderFailed:
                return "К сожалению, не удалось записаться. Попробуйте позднее."
            }
        }
        
    }
    
    private let orders: OrderService
    private let autos: UserAutoService
    private let auto: UserAuto
    private let serviceCenter: ServiceCenter
    private let selection: OrderTechServiceSelection
    private let variant: OrderTechServiceGetVariantsResponse.Variant
    private let disposeBag = DisposeBag()
    
    var submitButtonTitle: String {
        return "Подтвердить"
    }
    
    init(orders: OrderService, autos: UserAutoService, auto: UserAuto, serviceCenter: ServiceCenter, selection: OrderTechServiceSelection, variant: OrderTechServiceGetVariantsResponse.Variant) {
        self.orders = orders
        self.autos = autos
        self.auto = auto
        self.serviceCenter = serviceCenter
        self.selection = selection
        self.variant = variant
    }
    
    func observeData(onNext: @escaping (OrderTechServiceAppointmentDTO?) -> Void) {
        let object = OrderTechServiceAppointmentDTO(userAuto: auto, serviceCenter: serviceCenter, description: selection.description, price: selection.price, period: variant.range)
        onNext(object)
    }
    
    func sendData(completion: @escaping (Swift.Error?) -> Void) {
        orders.sendOrder(autoUid: auto.id, serviceUid: serviceCenter.uid, kind: selection.kind, date: variant.range.lowerBound)
            .flatMap { [autos] response in autos.pull().map { _ in response } }
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: {
                if $0.order.success {
                    completion(nil)
                } else {
                    completion(Error.sendOrderFailed)
                }
            }, onError: {
                completion($0)
            }).disposed(by: self.disposeBag)
    }
    
}
