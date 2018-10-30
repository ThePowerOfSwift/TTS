//
//  OrderTechServiceSendOrderResponse.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public struct OrderTechServiceSendOrderResponse: Codable {

    public struct Order: Codable {
        
        public let success: Bool
        
    }
    
    public let order: Order
    
}
