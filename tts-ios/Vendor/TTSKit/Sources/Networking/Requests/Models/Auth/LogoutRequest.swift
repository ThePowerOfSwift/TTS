//
//  LogoutRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 29/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

/// Очищает токен пользователя
struct LogoutRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    
    private let timeoutInterval: TimeInterval?
    
    init(timeoutInterval: TimeInterval? = nil) {
        self.timeoutInterval = timeoutInterval
    }
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/logout")
        var request = try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader)
        if let timeoutInterval = timeoutInterval {
            request.timeoutInterval = timeoutInterval
        }
        return request
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<VoidResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
