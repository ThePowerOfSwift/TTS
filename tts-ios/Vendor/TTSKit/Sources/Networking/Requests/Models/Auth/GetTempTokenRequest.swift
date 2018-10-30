//
//  GetTempTokenRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 25/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

/// В ответ на данный запрос API возвращает временный токен и отправляет смс с кодом, которые необходимы для получения постоянного токена в следующем запросе.
///
/// Время жизни временного токена – 20 минут. По истечении данного времени необходимо повторить запрос.
///
/// Интервал времени между запросами не должен быть менее 2 минут.
///
/// Время жизни access_token 30 дней. По истечении этого времени все запросы будут возвращать ошибку с кодом 7 (Token expired), в этом случае необходимо сделать запрос на продление access_token.
struct GetTempTokenRequest: NetworkRequest {
    
    /// Номер телефона пользователя в формате +7(999)999-99-99
    ///
    /// Соблюдение формата обязательно. Отклонение от указанного формата приведет к ошибке «Invalid phone number»
    var phone: PhoneNumber
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/getTempToken")
        var parameters = [String: Any]()
        parameters["phone"] = try PhoneNumberFormatter().apiRequestString(from: phone)
        return try URLRequestSerializer().request(url: url, method: .post, parameters: parameters)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<GetTempTokenResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
