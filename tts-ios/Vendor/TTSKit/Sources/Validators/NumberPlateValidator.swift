//
//  NumberPlateValidator.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 12/03/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

private let kAllowedLetters = CharacterSet(charactersIn: "АВЕКМНОРСТУХ")
private let kDeprecatedCharacters = CharacterSet.decimalDigits.union(kAllowedLetters).inverted

public final class NumberPlateValidator: Validator {
    
    enum Error: Swift.Error {
        case invalidLength
        case invalidFormat
        case invalidCharacters
    }
    
    public init() {}
    
    public func validate(_ value: String) throws {
        if value.contains(charactersIn: kDeprecatedCharacters) {
            throw Error.invalidCharacters
        }
        
        // validate length
        if !(8...9).contains(value.count) {
            throw Error.invalidLength
        }

        let index0 = value.startIndex
        let index1 = value.index(index0, offsetBy: 1)
        let index4 = value.index(index1, offsetBy: 3)
        let index6 = value.index(index4, offsetBy: 2)

        // first letter
        if String(value[index0..<index1]).contains(charactersIn: CharacterSet.letters.inverted) {
            throw Error.invalidFormat
        }

        // 3 digits
        if String(value[index1..<index4]).contains(charactersIn: CharacterSet.decimalDigits.inverted) {
            throw Error.invalidFormat
        }

        // last 2 digits
        if String(value[index4..<index6]).contains(charactersIn: CharacterSet.letters.inverted) {
            throw Error.invalidFormat
        }

        // 2 or 3 trailing numbers
        if String(value[index6..<value.endIndex]).contains(charactersIn: CharacterSet.decimalDigits.inverted) {
            throw Error.invalidFormat
        }
    }
    
}
