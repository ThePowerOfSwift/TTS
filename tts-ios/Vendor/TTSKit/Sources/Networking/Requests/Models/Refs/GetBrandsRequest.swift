//
//  GetBrandsRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 01/03/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Получение списка всех брендов
struct GetBrandsRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/getBrands")
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<GetBrandsResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
