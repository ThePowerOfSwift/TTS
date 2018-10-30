//
//  RepairService.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 29/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation
import RxSwift

public final class RepairService {
    
    private let client: URLRequestManaging
    
    public init(client: URLRequestManaging) {
        self.client = client
    }
    
    public func getUkr() -> Single<GetUkrResponse> {
        return client.execute(GetUkrRequest()).map {$0.value}
    }
    
    public func getUkrByCity(cityId: Int) -> Single<GetUkrResponse> {
        return client.execute(GetUkrByCityRequest(cityId: cityId)).map {$0.value}
    }
    
    public func callUkr(ukrUid: String, comment: String?) -> Single<MessageResponse> {
        return client.execute(CallUkrRequest(ukrUid: ukrUid, comment: comment)).map { $0.value }
    }
    
}
