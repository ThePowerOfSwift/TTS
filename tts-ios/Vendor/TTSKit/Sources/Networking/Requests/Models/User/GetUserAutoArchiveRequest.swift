//
//  GetUserAutoArchiveRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 12/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Информация об автомобилях пользователя в архиве
///
/// Возвращает информацию об автомобилях пользователя находящихся в архиве.
struct GetUserAutoArchiveRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/getUserAutoArchive")
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<GetUserAutoResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
