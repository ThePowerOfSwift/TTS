//
//  CallbackRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 16/03/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Форма обратной связи "Перезвоните мне"
struct CallbackRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/callback")
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<VoidResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
