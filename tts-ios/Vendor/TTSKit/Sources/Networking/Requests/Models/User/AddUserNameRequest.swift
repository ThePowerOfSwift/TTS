//
//  AddUserNameRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 28/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

/// Запрос на добавление имени пользователя
///
/// Запрос отправляется при регистрации пользователя если в наших базах пользователь с указанным номером не найден.
struct AddUserNameRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    var firstName: String
    var lastName: String
    
    init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/addUserName")
        var parameters = [String: Any]()
        parameters["user_name"] = ["name": firstName, "last_name": lastName]
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader, parameters: parameters)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<VoidResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
