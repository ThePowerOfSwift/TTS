//
//  PriceFormatter.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public final class PriceFormatter: Formatter {
    
    let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.ru_RU
        numberFormatter.numberStyle = .currency
        return numberFormatter
    }()

    public func string(from number: NSNumber) -> String? {
        return numberFormatter.string(from: number)
    }
    
    public override func string(for obj: Any?) -> String? {
        guard let number = obj as? NSNumber else { return nil }
        return string(from: number)
    }
    
}
