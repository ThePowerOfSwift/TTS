//
//  GetUserInfoRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 29/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

/// Информация о пользователе
///
/// Возвращает ФИО пользователя (одной строкой) и балы пользователя
struct GetUserInfoRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/getUserInfo")
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<UserInfo> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
