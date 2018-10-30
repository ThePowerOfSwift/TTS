//
//  DateToTimeTransformer.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 15/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public final class DateToTimeTransformer: ValueTransformer {
    
    public var calendar: Calendar?
    
    public func time(from date: Date) -> Time {
        let calendar: Calendar
        if let object = self.calendar {
            calendar = object
        } else {
            var object = Calendar.autoupdatingCurrent
            object.locale = Locale.ru_RU
            calendar = object
        }
        
        let components = calendar.dateComponents([.hour, .minute], from: date)
        return Time(hour: components.hour ?? 0, minute: components.minute ?? 0)
    }
    
    public override func transformedValue(_ value: Any?) -> Any? {
        guard let value = value as? Date else { return nil }
        return time(from: value)
    }
    
    public override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
}
