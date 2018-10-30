//
//  GetEquipmentsRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 10/03/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Получение списка модификаций по бренду, модели и году
struct GetEquipmentsRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    
    let brandId: Int
    let modelId: Int
    let year: Int
    
    init(brandId: Int, modelId: Int, year: Int) {
        self.brandId = brandId
        self.modelId = modelId
        self.year = year
    }
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/getEquipments")
        var parameters = [String: Any]()
        parameters["brand_id"] = brandId
        parameters["model_id"] = modelId
        parameters["year"] = year
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader, parameters: parameters)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<GetEquipmentsResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
