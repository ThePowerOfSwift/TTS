//
//  OrderTechServiceDetailSelectInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 08/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class OrderTechServiceDetailSelectInteractor {
    
    private let orders: OrderService
    private let autoUid: String
    private let serviceCenterUid: String
    private let techService: OrderTechServiceGetListResponse.Service
    private let details: OrderTechServiceGetDetailResponse
    private let disposeBag = DisposeBag()
    
    init(orders: OrderService, autoUid: String, serviceCenterUid: String, techService: OrderTechServiceGetListResponse.Service, details: OrderTechServiceGetDetailResponse) {
        self.orders = orders
        self.autoUid = autoUid
        self.serviceCenterUid = serviceCenterUid
        self.techService = techService
        self.details = details
    }
    
    func observeData(onNext: @escaping (OrderTechServiceGetListResponse.Service, OrderTechServiceGetDetailResponse) -> Void) {
        onNext(techService, details)
    }
    
}
