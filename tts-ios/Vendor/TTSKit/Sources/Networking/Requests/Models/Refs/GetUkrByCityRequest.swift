//
//  GetRepairPointByCityRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 20/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Список участков кузовного ремонта по ID города
struct GetUkrByCityRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    var cityId: Int
    
    init(cityId: Int) {
        self.cityId = cityId
    }
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/getUkrByCity")
        var parameters = [String: Any]()
        parameters["city_id"] = cityId
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader, parameters: parameters)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<GetUkrResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
