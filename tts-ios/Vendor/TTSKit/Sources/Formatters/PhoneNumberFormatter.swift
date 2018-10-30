//
//  PhoneNumberFormatter.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 01/04/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

private func PhoneNumberFormatterFullString(prefix: String, suffix: String) -> String {
    let index3 = suffix.index(suffix.startIndex, offsetBy: 3)
    let index6 = suffix.index(index3, offsetBy: 3)
    let index8 = suffix.index(index6, offsetBy: 2)
    return "\(prefix) (\(suffix[suffix.startIndex..<index3])) \(suffix[index3..<index6])-\(suffix[index6..<index8])-\(suffix[index8..<suffix.endIndex])"
}

public final class PhoneNumberFormatter: Formatter {
    
    /// Номер телефона в формате "+7 (999) 999-99-99" или "8 800 123 45 67"
    public func string(from phone: PhoneNumber) -> String {
        switch phone.format {
            
        case .free(let string):
            let index4 = string.index(string.startIndex, offsetBy: 4)
            let index7 = string.index(index4, offsetBy: 3)
            let index9 = string.index(index7, offsetBy: 2)
            return "8 800 \(string[index4..<index7]) \(string[index7..<index9]) \(string[index9..<string.endIndex])"
            
        case .short(let string):
            return PhoneNumberFormatterFullString(prefix: "+7", suffix: string)
            
        case .full(let prefix, let suffix):
            return PhoneNumberFormatterFullString(prefix: prefix, suffix: suffix)
        }
    }
    
    /// Номер телефона в формате "+7(999)999-99-99"
    public func apiRequestString(from phone: PhoneNumber) throws -> String {
        enum Error: Swift.Error {
            case invalidApiRequestPhoneFormat
        }
        
        switch phone.format {
        case .free:
            throw Error.invalidApiRequestPhoneFormat
            
        case .short(let string):
            return PhoneNumberFormatterFullString(prefix: "+7", suffix: string).replacing(charactersIn: CharacterSet.whitespaces, with: "")
            
        case .full(let prefix, let suffix):
            return PhoneNumberFormatterFullString(prefix: prefix, suffix: suffix).replacing(charactersIn: CharacterSet.whitespaces, with: "")
        }
    }
    
    public override func string(for obj: Any?) -> String? {
        guard let phone = obj as? PhoneNumber else { return nil }
        return string(from: phone)
    }
    
}
