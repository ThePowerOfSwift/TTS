//
//  CallUkrRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 29/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Форма "Запись на кузовной ремонт"
struct CallUkrRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    
    var ukrUid: String
    var comment: String?
    
    init(ukrUid: String, comment: String?) {
        self.ukrUid = ukrUid
        self.comment = comment
    }
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/callUkr")
        var parameters = [String: Any]()
        parameters["ukr_uid"] = ukrUid
        parameters["comment"] = comment
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader, parameters: parameters)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<MessageResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
