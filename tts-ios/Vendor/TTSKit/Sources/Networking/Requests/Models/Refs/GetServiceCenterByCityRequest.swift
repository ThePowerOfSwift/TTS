//
//  GetServiceCenterByCityRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 25/03/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Получение списка сервисных центров по id города
struct GetServiceCenterByCityRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    var cityId: Int
    
    init(cityId: Int) {
        self.cityId = cityId
    }
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/getServiceCenterByCity")
        let parameters = ["city_id": cityId]
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader, parameters: parameters)
    }

    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<GetServiceCenterResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }

}
