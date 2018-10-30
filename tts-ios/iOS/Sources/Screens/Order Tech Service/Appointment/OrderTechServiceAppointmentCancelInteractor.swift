//
//  OrderTechServiceAppointmentCancelInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 15/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class OrderTechServiceAppointmentCancelInteractor: OrderTechServiceAppointmentInteractorInput {
    
    private let orders: OrderService
    private let autos: UserAutoService
    private let autoId: String
    private let serviceCenter: ServiceCenter
    private let record: TechServiceRecord
    private let disposeBag = DisposeBag()
    
    var submitButtonTitle: String {
        return "Отменить"
    }
    
    init(orders: OrderService, autos: UserAutoService, autoId: String, serviceCenter: ServiceCenter, record: TechServiceRecord) {
        self.orders = orders
        self.autos = autos
        self.autoId = autoId
        self.serviceCenter = serviceCenter
        self.record = record
    }
    
    func observeData(onNext: @escaping (OrderTechServiceAppointmentDTO?) -> Void) {
        var strings = record.detail?.description.map { $0.operation } ?? []
        if let string = record.name {
           strings.insert(string, at: 0)
        }
        
        let price = record.detail?.total ?? .unknown
        
        autos.observe(id: autoId)
            .observeOn(MainScheduler.instance)
            .map { [serviceCenter, record] in $0.flatMap { OrderTechServiceAppointmentDTO(userAuto: $0, serviceCenter: serviceCenter, description: strings.joined(separator: "\n"), price: price, period: record.period) } }
            .subscribe(onNext: onNext)
            .disposed(by: disposeBag)
    }
    
    func sendData(completion: @escaping (Swift.Error?) -> Void) {
        orders.deleteRecord(recordId: record.id)
            .flatMap { [autos] response in autos.pull().map { _ in response } }
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { _ in
                completion(nil)
            }, onError: {
                completion($0)
            }).disposed(by: self.disposeBag)
    }
    
}
