//
//  GetAccessTokenResponse.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 25/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public struct GetAccessTokenResponse: Codable {
    
    public enum StatusCode: Int, Codable {
        case userNotFound = 0
        case userFound = 1
    }
    
    /// Постоянный токен (access_token) который необходимо использовать при всех последующих запросах для аутентификации пользователя
    public let access_token: String
    
    /// Параметр который используется для продления (обновления) access_token
    ///
    /// Данный параметр необходимо сохранить локально.
    public let extension_token: String
    
    public let status: String
    
    /// Параметр определяющий есть ли информация о пользователе с таким номером телефона в наших базах.
    public let status_code: StatusCode
    
}
