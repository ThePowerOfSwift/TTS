//
//  GetUserAutoRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 02/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Информация об автомобилях пользователя не находящихся в архиве
///
/// Возвращает информацию об автомобилях пользователя не находящихся в архиве, а также информацию о сервисном центре, к которому привязан автомобиль (если автомобиль привязан к СЦ)
struct GetUserAutoRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    
    init() {
        
    }
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/getUserAuto")
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<GetUserAutoResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
