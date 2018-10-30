//
//  OrderTechServiceDetailDescription.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 17/07/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public struct OrderTechServiceDetailDescription: Codable, Equatable {
    
    public let operation: String
    
    public let tag: String
    
    public let importance: String
    
}
