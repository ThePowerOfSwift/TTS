//
//  PlateNumberFormatter.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 11/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public final class PlateNumberFormatter: Formatter {
    
    public func numberAttributedString(for plateNumber: PlateNumber, lettersAttributes: StringAttributes, numbersAttributes: StringAttributes) -> NSAttributedString {
        let string = plateNumber.number
        
        let result = NSMutableAttributedString(string: string, attributes: lettersAttributes)
        
        for range in string.rangesOfCharacters(from: .decimalDigits, options: []) {
            let nsRange = NSRange(range, in: string)
            result.setAttributes(numbersAttributes, range: nsRange)
        }
        
        return result.copy() as! NSAttributedString // swiftlint:disable:this force_cast
    }
    
}
