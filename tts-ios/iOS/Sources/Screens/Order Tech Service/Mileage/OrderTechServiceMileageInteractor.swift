//
//  OrderTechServiceMileageInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 05/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class OrderTechServiceMileageInteractor {
    
    private let orders: OrderService
    private let autoUid: String
    private let disposeBag = DisposeBag()
    
    init(orders: OrderService, autoUid: String) {
        self.orders = orders
        self.autoUid = autoUid
    }
    
    func getList(mileage: Int?, completion: ((Result<OrderTechServiceGetListResponse>) -> Void)?) {
        orders.getList(autoUid: autoUid, mileage: mileage)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: {
                completion?(Result(value: $0))
            }, onError: {
                completion?(Result(error: $0))
            }).disposed(by: disposeBag)
    }
    
}
