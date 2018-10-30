//
//  MileageValidator.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 12/03/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

private let kDeprecatedCharacters = CharacterSet.decimalDigits.inverted

public final class MileageValidator: Validator {
    
    enum Error: Swift.Error {
        case maxLengthExceeded
        case invalidFormat
        case canNotBeNull
    }
    
    public init() {}
    
    public func validate(_ value: String) throws {
        if value.count > 6 {
            throw Error.maxLengthExceeded
        }
        
        if value.contains(charactersIn: kDeprecatedCharacters) {
            throw Error.invalidFormat
        }
        
        let formatter = NumberFormatter()
        if let number = formatter.number(from: value), number.intValue == 0 {
            throw Error.canNotBeNull
        }
    }
    
    public func isChangeAllowed(_ value: String?) -> Bool {
        guard let value = value else { return true }
        
        do {
            try validate(value)
            return true
        } catch Error.canNotBeNull {
            return true
        } catch {
            return false
        }
    }
    
}
