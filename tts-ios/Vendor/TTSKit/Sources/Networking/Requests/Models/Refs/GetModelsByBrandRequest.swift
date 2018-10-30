//
//  GetModelsByBrandRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 10/03/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Список моделей бренда
struct GetModelsByBrandRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    
    let brandId: Int
    
    init(brandId: Int) {
        self.brandId = brandId
    }
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/getModelsByBrand")
        var parameters = [String: Any]()
        parameters["brand_id"] = brandId
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader, parameters: parameters)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<GetModelsByBrandResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
