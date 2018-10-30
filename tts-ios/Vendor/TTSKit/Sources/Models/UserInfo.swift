//
//  UserInfo.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 29/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public struct UserInfo: Codable, Equatable {
    
    enum CodingKeys: String, CodingKey {
        case name
        case phone
        case bonuses
        case pushStatus = "push_status"
    }
    
    /// ФИО пользователя
    public let name: String?
    
    /// Телефон
    public let phone: PhoneNumber
    
    /// Количество бонусов пользователя
    public let bonuses: NSDecimalNumber
    
    /// Статус push-уведомлений
    public let pushStatus: PushStatus
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decodeIfPresent(String.self, forKey: .name)
        phone = try PhoneNumber(try container.decode(String.self, forKey: .phone))
        
        if let bonuses = try? container.decode(Double.self, forKey: .bonuses) {
            self.bonuses = NSDecimalNumber(value: bonuses)
        } else {
            let string = try container.decode(String.self, forKey: .bonuses)
            bonuses = try DecimalTransformer().number(from: string)
        }
        pushStatus = try container.decode(PushStatus.self, forKey: .pushStatus)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(phone.rawValue, forKey: .phone)
        try container.encode(bonuses.stringValue, forKey: .bonuses)
        try container.encode(pushStatus, forKey: .pushStatus)
    }
    
}
