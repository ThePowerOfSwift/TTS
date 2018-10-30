//
//  SetPushNotifyRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 27/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Устанавливает статус push-уведомлений
struct SetPushNotifyRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    
    /// Статус уведомлений
    ///
    /// Включить - 1
    /// Выключить – 0, либо не передавать параметр
    let pushStatus: PushStatus?
    
    init(pushStatus: PushStatus? = nil) {
        self.pushStatus = pushStatus
    }
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/setPushNotify")
        var parameters = [String: Any]()
        if let pushStatus = pushStatus {
            parameters["push_status"] = pushStatus.rawValue
        }
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader, parameters: parameters)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<SetPushStatusResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
