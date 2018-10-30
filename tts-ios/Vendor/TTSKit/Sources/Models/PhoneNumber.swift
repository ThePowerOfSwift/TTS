//
//  PhoneNumber.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 28/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

private let kRegexp1 = try! NSRegularExpression(pattern: "\\+\\d{1,3}\\(\\d{3}\\)\\d{3}-\\d{2}-\\d{2}", options: []) // swiftlint:disable:this force_try
private let kRegexp2 = try! NSRegularExpression(pattern: "8800\\d{7}", options: []) // swiftlint:disable:this force_try
private let kInvalidCharacters = CharacterSet.decimalDigits.inverted

/// Номер телефона
public struct PhoneNumber: Codable, Equatable {
    
    enum Error: Swift.Error {
        case invalidFormat(String)
    }
    
    enum Format: Codable {
        
        enum CodingKeys: CodingKey {
            case short
            case free
            case full
        }
        
        case short(String)
        
        case free(String)
        
        case full(String, String)
        
        var rawValue: String {
            switch self {
            case .short(let string):
                return string
            case .free(let string):
                return string
            case .full(let prefix, let suffix):
                return prefix + suffix
            }
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let key = container.allKeys.first!
            
            switch key {
            case .short:
                self = .short(try container.decode(String.self, forKey: .short))
            case .free:
                self = .free(try container.decode(String.self, forKey: .free))
            case .full:
                let strings = try container.decode([String].self, forKey: .full)
                guard strings.count == 2 else { throw DecodingError.dataCorruptedError(forKey: .full, in: container, debugDescription: "Full PhoneNumber Format should contain 2 string elements.") }
                self = .full(strings[0], strings[1])
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            switch self {
            case .short(let string):
                try container.encode(string, forKey: .short)
            case .free(let string):
                try container.encode(string, forKey: .free)
            case .full(let prefix, let suffix):
                try container.encode([prefix, suffix], forKey: .full)
            }
        }
        
    }
    
    let format: Format
    
    public var rawValue: String {
        return format.rawValue
    }
    
    /// "9991234567" — without country prefix "+7"
    public init(short string: String) throws {
        guard string.count == 10, !string.contains(charactersIn: kInvalidCharacters) else {
            throw Error.invalidFormat(string)
        }
        format = .short(string)
    }
    
    /// "88001234567"
    public init(free string: String) throws {
        guard string.count == 11, string.hasPrefix("8800"), !string.contains(charactersIn: kInvalidCharacters) else {
            throw Error.invalidFormat(string)
        }
        format = .free(string)
    }
    
    public init(full string: String) throws {
        var int: Int = 0
        guard Scanner(string: string).scanInt(&int) else {
            throw Error.invalidFormat(string)
        }
        
        let prefix = String(int)
        let digits = string.replacing(charactersIn: CharacterSet.decimalDigits.inverted, with: "")
        let suffix = String(digits[prefix.endIndex...])
        
        guard prefix.count <= 3, suffix.count == 10 else {
            throw Error.invalidFormat(string)
        }
        
        format = .full("+" + prefix, suffix)
    }
    
    /// Autodetect string format
    public init(_ string: String) throws {
        do {
            try self.init(full: string)
        } catch {
            do {
                try self.init(short: string)
            } catch {
                try self.init(free: string)
            }
        }
    }
    
    public static func == (lhs: PhoneNumber, rhs: PhoneNumber) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
}
