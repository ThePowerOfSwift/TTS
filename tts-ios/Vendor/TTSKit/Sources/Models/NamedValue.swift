//
//  NamedValue.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 10/03/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public struct NamedValue: Codable, Hashable {
    
    public let id: Int
    
    public let name: String
    
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
}
