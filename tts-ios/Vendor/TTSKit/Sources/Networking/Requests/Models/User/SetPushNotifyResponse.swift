//
//  SetPushNotifyResponse.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 17/07/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public struct SetPushStatusResponse: Codable {
    
    enum CodingKeys: String, CodingKey {
        case pushStatus = "push_status"
    }
    
    public let pushStatus: Int
    
}
