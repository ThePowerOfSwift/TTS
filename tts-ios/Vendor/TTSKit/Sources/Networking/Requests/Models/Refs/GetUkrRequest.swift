//
//  GetUkrRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 19/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Список всех участков кузовного ремонта
struct GetUkrRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/getUkr")
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<GetUkrResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
