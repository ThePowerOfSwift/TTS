//
//  GetServiceCenterRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 25/03/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Получение списка сервисных центров
struct GetServiceCenterRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    
    init() {}
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/getServiceCenter")
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> [ServiceCenter] {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
