//
//  OrderTechServiceGetDetailRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 21/05/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Детальная информация о ТО. Список типов ТО с расчетом стоимости и описанием работ и зап частей
struct OrderTechServiceGetDetailRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    var autoUid: String
    var tsUid: String
    var serviceUid: String
    
    init(autoUid: String, tsUid: String, serviceUid: String) {
        self.autoUid = autoUid
        self.tsUid = tsUid
        self.serviceUid = serviceUid
    }
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/order/techService/getDetail")
        var parameters = [String: Any]()
        parameters["auto_uid"] = autoUid
        parameters["ts_uid"] = tsUid
        parameters["service_uid"] = serviceUid
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader, parameters: parameters)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<OrderTechServiceGetDetailResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
