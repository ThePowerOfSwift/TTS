//
//  MileageMask.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 07/05/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public final class MileageMask: TextMask {
    
    private let validator = MileageValidator()
    
    public init() {
        
    }
    
    public func maskedString(from string: String, cursorPosition: inout Int?) -> String {
        return string
    }
    
    public func unmaskedString(from string: String, cursorPosition: inout Int?) -> String {
        return string
    }
    
    public func shouldChange(text: String?, with string: String, in range: NSRange) -> Bool {
        let value = (text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        return validator.isChangeAllowed(value)
    }
    
}
