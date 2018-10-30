//
//  PhoneMask.swift
//  tts
//
//  Created by Dmitry Nesterenko on 22/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

/// Phone number mask
///
/// +7 (918) 999-99-99
public final class PhoneMask: TextMask {
    
    /// Specifies not editable phone number prefix
    ///
    /// Prefix will be separated by a whitespace from the actual phone number. No whitespaces. Example: "+7"
    var prefix: String?

    public init(prefix: String? = nil) {
        self.prefix = prefix
    }
    
    public func shouldChange(text: String?, with string: String, in range: NSRange) -> Bool {
        if string.count == 0 {
            return true
        }

        let textLength: Int = text?.count ?? 0
        let prefix: String = self.prefix?.appending(" ") ?? ""

        // Consider first symbol of a mask "(" to be a part of the prefix
        var prefixLength = prefix.count
        if prefixLength > 0, textLength >= prefixLength + 1 {
            prefixLength += 1
        }
        
        let isRangeAffectsPrefix: Bool = range.location + range.length <= prefixLength && range.location < prefixLength
        if isRangeAffectsPrefix {
            // can't modify prefix
            return false
        }
        
        let result: String = (text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        let unmasked = unmaskedString(from: result)
        let maxLength: Int = 10 + (self.prefix ?? "").count
        if unmasked.count > maxLength {
            // can't exceed max length
            return false
        }
        
        return true
    }
    
    public func unmaskedString(from maskedString: String, cursorPosition: inout Int?) -> String {
        let prefix = self.prefix ?? ""
        
        // obtain initial cursor positions
        var originalCursorPosition = cursorPosition ?? 0
        var filteredCursorPosition = cursorPosition ?? 0
        
        // append prefix to the cursor positions
        var prefixed = maskedString
        if !maskedString.hasPrefix(prefix) {
            prefixed = prefix.appending(maskedString)
            originalCursorPosition += prefix.count
            filteredCursorPosition += prefix.count
        }
        
        // filter all characters but digits
        var filtered = prefix
        let suffix = prefixed.suffix(from: prefix.endIndex)
        for (offset, character) in suffix.enumerated() {
            let isDigit = character.unicodeScalars.count == 1 && CharacterSet.decimalDigits.contains(character.unicodeScalars.first!)
            if isDigit {
                filtered.append(character)
            } else {
                if offset + prefix.count < originalCursorPosition {
                    filteredCursorPosition -= 1
                }
            }
        }
        
        cursorPosition = filteredCursorPosition
        
        return filtered
    }
    
    public func maskedString(from unmaskedString: String, cursorPosition: inout Int?) -> String {
        let unmaskedString = self.unmaskedString(from: unmaskedString, cursorPosition: &cursorPosition)

        var prefix = self.prefix ?? ""

        // obtain initial cursor positions
        var originalCursorPosition = cursorPosition ?? 0
        var maskedCursorPosition = cursorPosition ?? 0
        
        // append prefix to the cursor positions
        var prefixed: String
        if !unmaskedString.hasPrefix(prefix), prefix.count > 0 {
            prefixed = prefix.appending(unmaskedString)
            originalCursorPosition += prefix.count
            maskedCursorPosition += prefix.count
        } else {
            prefixed = unmaskedString
        }
        
        // append whitespace after prefix
        if prefix.count > 0 {
            prefixed.insert(" ", at: prefix.endIndex)
            prefix.append(" ")
            originalCursorPosition += 1
            maskedCursorPosition += 1
        }
        
        var result = prefix
        let substring = prefixed[prefix.endIndex...]
        for index in substring.indices {
            let character = substring[index]
            let distance = prefix.count + substring.distance(from: substring.startIndex, to: index)

            if distance - prefix.count == 0 {
                if distance < originalCursorPosition {
                    maskedCursorPosition += 1
                }
                result.append("(")
            }
            
            if distance - prefix.count == 3 {
                if distance < originalCursorPosition {
                    maskedCursorPosition += 2
                }
                result.append(") ")
            }
            
            if distance - prefix.count == 6 || distance - prefix.count == 8 {
                if distance < originalCursorPosition {
                    maskedCursorPosition += 1
                }
                result.append("-")
            }
            
            result.append(character)
        }
        
        cursorPosition = max(maskedCursorPosition, prefix.count)
        
        return result
    }
    
}
