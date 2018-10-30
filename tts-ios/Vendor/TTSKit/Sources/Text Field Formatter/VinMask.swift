//
//  VinMask.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 07/05/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public final class VinMask: TextMask {
    
    private let validator = VinValidator()
    
    public init() {
        
    }
    
    public func maskedString(from string: String, cursorPosition: inout Int?) -> String {
        return UppercaseMask().maskedString(from: string, cursorPosition: &cursorPosition)
    }
    
    public func unmaskedString(from string: String, cursorPosition: inout Int?) -> String {
        return UppercaseMask().unmaskedString(from: string, cursorPosition: &cursorPosition)
    }
    
    public func shouldChange(text: String?, with string: String, in range: NSRange) -> Bool {
        let value = (text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        return validator.isChangeAllowed(value)
    }
    
}
