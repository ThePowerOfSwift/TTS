//
//  OrderTechServiceDeleteRecordRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 22/05/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Запрос на удаление записи на ТО
struct OrderTechServiceDeleteRecordRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    var recordId: String
    
    init(recordId: String) {
        self.recordId = recordId
    }
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/order/techService/deleteRecord")
        var parameters = [String: Any]()
        parameters["record_id"] = recordId
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader, parameters: parameters)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<OrderTechServiceDeleteRecordResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
