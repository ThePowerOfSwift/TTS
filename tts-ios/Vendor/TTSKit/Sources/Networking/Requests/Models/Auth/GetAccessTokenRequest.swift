//
//  GetAccessTokenRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 25/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

/// Запрос постоянного токена
struct GetAccessTokenRequest: NetworkRequest {
    
    /// Номер телефона пользователя в формате +7(999)999-99-99
    var phone: PhoneNumber
    
    /// Временный токен полученный в ответе getTempToken
    var temp_token: String
    
    /// Код полученный в СМС
    var sms_code: String
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/getAccessToken")
        var parameters = [String: Any]()
        parameters["phone"] = try PhoneNumberFormatter().apiRequestString(from: phone)
        parameters["temp_token"] = temp_token
        parameters["sms_code"] = sms_code
        return try URLRequestSerializer().request(url: url, method: .post, parameters: parameters)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<GetAccessTokenResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
