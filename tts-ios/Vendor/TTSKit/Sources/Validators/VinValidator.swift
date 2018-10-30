//
//  VinValidator.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 12/03/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

private let kDeprecatedCharacters = CharacterSet.alphanumerics.inverted.union(CharacterSet(charactersIn: "ioqIOQ"))

/// - See: [Vehicle identification number](https://en.wikipedia.org/wiki/Vehicle_identification_number)
public final class VinValidator: Validator {
    
    enum Error: Swift.Error {
        case notEnoughLength
        case maxLengthExceeded
        case invalidFormat
    }
    
    public init() {}
    
    public func validate(_ value: String) throws {
        if value.count > 17 {
            throw Error.maxLengthExceeded
        }
        
        /// It required all on-road vehicles sold to contain a 17-character VIN, which does not include the letters I (i), O (o), and Q (q) (to avoid confusion with numerals 1 and 0).
        if value.contains(charactersIn: kDeprecatedCharacters) {
            throw Error.invalidFormat
        }
        
        if value.count < 17 {
            throw Error.notEnoughLength
        }
    }
    
    public func isChangeAllowed(_ value: String?) -> Bool {
        guard let value = value else { return true }
        
        do {
            try validate(value)
            return true
        } catch Error.notEnoughLength {
            return true
        } catch {
            return false
        }
    }
    
}
