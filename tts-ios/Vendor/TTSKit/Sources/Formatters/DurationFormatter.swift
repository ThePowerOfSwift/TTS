//
//  DurationFormatter.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public final class DurationFormatter: Formatter {
    
    public var calendar: Calendar? {
        get {
            return dateComponentsFormatter.calendar
        }
        set {
            dateComponentsFormatter.calendar = newValue
        }
    }
    
    private let dateComponentsFormatter: DateComponentsFormatter = {
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.unitsStyle = .abbreviated
        return dateComponentsFormatter
    }()
    
    public func string(from range: Range<Date>) -> String? {
        let calendar = self.calendar ?? Calendar.autoupdatingCurrent
        let components = calendar.dateComponents([.hour, .minute], from: range.lowerBound, to: range.upperBound)
        return dateComponentsFormatter.string(from: components)
    }
    
    public override func string(for obj: Any?) -> String? {
        guard let range = obj as? Range<Date> else { return nil }
        return string(from: range)
    }
    
}
