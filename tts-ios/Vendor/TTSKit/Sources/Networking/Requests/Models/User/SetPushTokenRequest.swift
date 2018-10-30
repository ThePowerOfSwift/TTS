//
//  SetPushTokenRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 12/07/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Установка токена для push-уведомлений
struct SetPushTokenRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    
    let token: String
    
    init(token: String) {
        self.token = token
    }
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/setPushToken")
        var parameters = [String: Any]()
        parameters["token"] = token
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader, parameters: parameters)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<VoidResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
