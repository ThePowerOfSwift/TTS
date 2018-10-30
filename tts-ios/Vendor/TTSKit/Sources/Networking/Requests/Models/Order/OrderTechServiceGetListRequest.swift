//
//  OrderTechServiceGetListRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 21/05/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Список видов Тех обслуживания, с выводом рекомендуемого в зависимости от пробега авто и года покупки
struct OrderTechServiceGetListRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    var autoUid: String
    var mileage: Int?
    
    init(autoUid: String, mileage: Int?) {
        self.autoUid = autoUid
        self.mileage = mileage
    }
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/order/techService/getList")
        var parameters = [String: Any]()
        parameters["auto_uid"] = autoUid
        if let mileage = mileage {
            parameters["mileage"] = mileage
        }
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader, parameters: parameters)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<OrderTechServiceGetListResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
