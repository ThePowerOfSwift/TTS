//
//  DecimalTransformer.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 07/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

final class DecimalTransformer: ValueTransformer {
    
    enum Error: Swift.Error {
        case invalidStringFormat
    }
    
    private let numberFormatter: NumberFormatter = {
        let result = NumberFormatter()
        result.generatesDecimalNumbers = true
        result.decimalSeparator = "."
        return result
    }()
    
    var locale: Locale? {
        didSet {
            numberFormatter.locale = locale
        }
    }
    
    func numberIfPresent(from string: String?) throws -> NSDecimalNumber? {
        guard let string = string else { return nil }
        return try number(from: string)
    }
    
    func number(from string: String) throws -> NSDecimalNumber {
        guard let value = numberFormatter.number(from: string) as? NSDecimalNumber else {
            throw Error.invalidStringFormat
        }
        return value
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let string = value as? String else { return nil }
        return try? number(from: string)
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
}
