//
//  MessageResponse.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 29/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public struct MessageResponse: Codable {
    
    public let error: Int
    public let message: String
    
}
