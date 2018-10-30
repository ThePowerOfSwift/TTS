//
//  TimeFormatter.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public final class TimeFormatter: Formatter {
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "HH:mm", options: 0, locale: nil)
        return dateFormatter
    }()
    
    public func string(from date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    public func string(from time: Time) -> String {
        return String(format: "%02d:%02d", time.hour, time.minute)
    }
    
    public override func string(for obj: Any?) -> String? {
        if let date = obj as? Date {
            return string(from: date)
        } else if let time = obj as? Time {
            return string(from: time)
        }
        return nil
    }
    
}
