//
//  TechServicePrice.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 15/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public enum TechServicePrice: Codable, Equatable {
    
    case unknown
    case value(NSDecimalNumber)
    
    public var number: NSDecimalNumber {
        switch self {
        case .unknown:
            return -1
        case .value(let number):
            return number
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        let number: NSDecimalNumber
        if let string = try? container.decode(String.self) {
            number = try DecimalTransformer().number(from: string)
        } else {
            let double = try container.decode(Double.self)
            number = NSDecimalNumber(value: double)
        }
        self.init(number: number)
    }
    
    public init(number: NSDecimalNumber) {
        if number == type(of: self).unknown.number {
            self = .unknown
        } else {
            self = .value(number)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(number.stringValue)
        
//        let number = try DecimalTransformer().number(from: try container.decode(String.self, forKey: .total))
    }
    
}
