//
//  GetServiceCenterByCityBrandRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 25/03/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Получение списка сервисных центров по id города и id бренда
struct GetServiceCenterByCityBrandRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    var cityId: Int
    var brandId: Int
    
    init(cityId: Int, brandId: Int) {
        self.cityId = cityId
        self.brandId = brandId
    }
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/getServiceCenterByCityBrand")
        let parameters = ["city_id": cityId,
                          "brand_id": brandId]
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader, parameters: parameters)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<GetServiceCenterResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
