//
//  PhoneNumberValidator.swift
//  tts
//
//  Created by Dmitry Nesterenko on 26/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import TTSKit

/// Validates if a string contains 10 digits
public final class PhoneNumberValidator: Validator {
    
    public enum Error: Swift.Error {
        
        case invalid
        
        case maxLengthExceeded
        
    }
    
    public var prefix: String?
    
    public init(prefix: String? = nil) {
        self.prefix = prefix
    }
    
    public func validate(_ value: String?) throws {
        guard let value = value else {
            throw Error.invalid
        }
        
        var phone = value
        if let prefix = prefix, value.hasPrefix(prefix) {
            phone = String(value[prefix.endIndex...])
        }
        
        // validate characters
        let containsDigitsOnly = (phone as NSString).rangeOfCharacter(from: CharacterSet.decimalDigits.inverted).location == NSNotFound
        if !containsDigitsOnly {
            throw Error.invalid
        }
        
        // validate length
        switch phone.count {
            
        case let x where x > 10:
            throw Error.maxLengthExceeded
            
        case let x where x == 10:
            break
            
        default:
            throw Error.invalid
            
        }
    }
    
}
