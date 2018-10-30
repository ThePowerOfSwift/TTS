//
//  OrderTechServiceDetailInteractor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 11/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit
import RxSwift

final class OrderTechServiceDetailInteractor {
    
    private let techService: OrderTechServiceGetListResponse.Service
    private let detail: OrderTechServiceGetDetailResponse.Detail
    
    init(techService: OrderTechServiceGetListResponse.Service, detail: OrderTechServiceGetDetailResponse.Detail) {
        self.techService = techService
        self.detail = detail
    }
    
    func observeData(onNext: @escaping (OrderTechServiceGetListResponse.Service, OrderTechServiceGetDetailResponse.Detail) -> Void) {
        onNext(techService, detail)
    }
    
}
