//
//  OrderTechServiceListInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 07/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class OrderTechServiceListInteractor {
    
    private let orders: OrderService
    private let autoUid: String
    private let list: OrderTechServiceGetListResponse
    private let disposeBag = DisposeBag()
    
    init(orders: OrderService, autoUid: String, list: OrderTechServiceGetListResponse) {
        self.orders = orders
        self.autoUid = autoUid
        self.list = list
    }
    
    func observeData(onNext: @escaping (OrderTechServiceGetListResponse) -> Void) {
        onNext(list)
    }
    
}
