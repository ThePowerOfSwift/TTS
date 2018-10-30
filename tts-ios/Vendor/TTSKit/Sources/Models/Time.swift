//
//  Time.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 21/05/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public struct Time: Codable {
    
    public var hour: Int = 0
    
    public var minute: Int = 0
    
    public init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
    
}
