//
//  BindingServiceCenterRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 24/04/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Привязка авто к сервисному центру по vin авто и uid СЦ
struct BindingServiceCenterRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    
    var uid: String

    var vin: String
    
    init(uid: String, vin: String) {
        self.uid = uid
        self.vin = vin
    }
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/bindingServiceCenter")
        var parameters = [String: Any]()
        parameters["service_uid"] = uid
        parameters["vin"] = vin
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader, parameters: parameters)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<VoidResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
