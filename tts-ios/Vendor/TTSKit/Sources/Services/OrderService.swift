//
//  OrderService.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 22/05/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation
import RxSwift

public final class OrderService {
    
    private let client: URLRequestManaging
    
    public init(client: URLRequestManaging) {
        self.client = client
    }
    
    public func getList(autoUid: String, mileage: Int?) -> Single<OrderTechServiceGetListResponse> {
        let request = OrderTechServiceGetListRequest(autoUid: autoUid, mileage: mileage)
        return client.execute(request).map {$0.value}
    }
    
    public func getDetail(autoUid: String, tsUid: String, serviceUid: String) -> Single<OrderTechServiceGetDetailResponse> {
        let request = OrderTechServiceGetDetailRequest(autoUid: autoUid, tsUid: tsUid, serviceUid: serviceUid)
        return client.execute(request).map {$0.value}
    }
    
    public func getVariants(autoUid: String, serviceUid: String, kind: TechServiceOrderKind, date: Date) -> Single<OrderTechServiceGetVariantsResponse> {
        let request = OrderTechServiceGetVariantsRequest(autoUid: autoUid, serviceUid: serviceUid, kind: kind, date: date)
        return client.execute(request).map {$0.value}
    }
    
    public func sendOrder(autoUid: String, serviceUid: String, kind: TechServiceOrderKind, date: Date) -> Single<OrderTechServiceSendOrderResponse> {
        let request = OrderTechServiceSendOrderRequest(autoUid: autoUid, serviceUid: serviceUid, kind: kind, date: date)
        return client.execute(request).map {$0.value}
    }
    
    public func getRecordDetail(recordId: Int) -> Single<VoidResponse> {
        let request = OrderTechServiceGetRecordDetailRequest(recordId: recordId)
        return client.execute(request).map {$0.value}
    }
    
    public func deleteRecord(recordId: String) -> Single<OrderTechServiceDeleteRecordResponse> {
        let request = OrderTechServiceDeleteRecordRequest(recordId: recordId)
        return client.execute(request).map {$0.value}
    }
    
}
