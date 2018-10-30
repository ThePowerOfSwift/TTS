//
//  BalanceFormatter.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 19/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public final class BalanceFormatter: Formatter {
    
    private let formatter: NumberFormatter = {
        var result = NumberFormatter()
        result.numberStyle = .currency
        result.minusSign = "−" // unicode minus sign
        result.plusSign = "+"
        return result
    }()
    
    public var locale: Locale {
        get {
            return formatter.locale
        }
        set {
            formatter.locale = newValue
        }
    }
    
    public var currencyCode: String? {
        didSet {
            formatter.currencyCode = currencyCode
        }
    }
    
    public var numberStyle: NumberFormatter.Style {
        get {
            return formatter.numberStyle
        }
        set {
            formatter.numberStyle = newValue
        }
    }
    
    public var currencySymbol: String? {
        didSet {
            formatter.currencySymbol = currencySymbol
        }
    }
    
    public var prefixSign: Bool = false {
        didSet {
            if prefixSign {
                formatter.negativePrefix = formatter.minusSign
                formatter.positivePrefix = formatter.plusSign
            } else {
                formatter.negativePrefix = nil
                formatter.positivePrefix = nil
            }
        }
    }
    
    public func stringIfPresent(from number: NSNumber?) -> String? {
        guard let number = number else { return nil }
        return string(from: number)
    }
    
    public func string(from number: NSNumber) -> String? {
        if number.doubleValue == number.doubleValue.rounded() {
            formatter.maximumFractionDigits = 0
        } else {
            formatter.maximumFractionDigits = 2
        }
        return formatter.string(from: number)
    }
    
    public override func string(for obj: Any?) -> String? {
        guard let number = obj as? NSNumber else { return nil }
        return string(from: number)
    }
    
}
