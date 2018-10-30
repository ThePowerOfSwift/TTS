//
//  ExtensionTokenRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 29/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

/// Запрос на продление постоянного токена
struct ExtensionTokenRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    
    /// Токен для восстановления access_token полученный в запросе  getAccessToken
    var extensionToken: String
    
    init(extensionToken: String) {
        self.extensionToken = extensionToken
    }
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/extensionToken")
        var parameters = [String: Any]()
        parameters["extension_token"] = extensionToken
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader, parameters: parameters)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<ExtensionTokenResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
