//
//  TextMask.swift
//  tts
//
//  Created by Dmitry Nesterenko on 22/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public protocol TextMask {
    
    func shouldChange(text: String?, with string: String, in range: NSRange) -> Bool
    
    /// Returns unmasked string with prefix appended
    func unmaskedString(from string: String, cursorPosition: inout Int?) -> String
    
    /// Returns unmasked string with prefix appended
    func maskedString(from string: String, cursorPosition: inout Int?) -> String
    
}

extension TextMask {
    
    public func unmaskedString(from string: String) -> String {
        var cursorPosition: Int?
        return unmaskedString(from: string, cursorPosition: &cursorPosition)
    }
    
    public func maskedString(from string: String) -> String {
        var cursorPosition: Int?
        return maskedString(from: string, cursorPosition: &cursorPosition)
    }
    
}
