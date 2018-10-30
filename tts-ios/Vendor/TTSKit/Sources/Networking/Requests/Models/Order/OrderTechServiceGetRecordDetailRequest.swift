//
//  OrderTechServiceGetRecordDetailRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 22/05/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Запрос детальной информации о записи на ТО
struct OrderTechServiceGetRecordDetailRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    var recordId: Int
    
    init(recordId: Int) {
        self.recordId = recordId
    }
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/order/techService/getRecordDetail")
        var parameters = [String: Any]()
        parameters["record_id"] = recordId
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader, parameters: parameters)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<VoidResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
