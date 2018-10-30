//
//  GetServiceCenterGroupRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 25/03/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Получение списка всех сервисных центров сгруппированых по адресу
struct GetServiceCenterGroupRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    
    init() {}
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/getServiceCenterGroup")
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<GetServiceCenterGroupResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
