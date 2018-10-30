//
//  OrderTechServiceProposeInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 06/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class OrderTechServiceProposeInteractor {
    
    private let orders: OrderService
    private let autoUid: String
    private let serviceCenter: ServiceCenter
    private let list: OrderTechServiceGetListResponse
    private let disposeBag = DisposeBag()
    
    init(orders: OrderService, autoUid: String, serviceCenter: ServiceCenter, list: OrderTechServiceGetListResponse) {
        self.orders = orders
        self.autoUid = autoUid
        self.serviceCenter = serviceCenter
        self.list = list
    }
    
    func observeData(onNext: @escaping (OrderTechServiceGetListResponse, [PhoneNumber]) -> Void) {
        onNext(list, serviceCenter.phone)
    }
    
    func getDetail(techServiceUid: String, completion: @escaping (Result<OrderTechServiceGetDetailResponse>) -> Void) {
        orders.getDetail(autoUid: autoUid, tsUid: techServiceUid, serviceUid: serviceCenter.uid)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { 
                completion(Result(value: $0))
            }, onError: {
                completion(Result(error: $0))
            }).disposed(by: disposeBag)
    }
    
}
