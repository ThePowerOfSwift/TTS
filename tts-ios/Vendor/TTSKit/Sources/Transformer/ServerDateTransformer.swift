//
//  ServerDateTransformer.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Date transformer with "yyyy-MM-dd HH:mm:ss" date format
final class ServerDateTransformer: ValueTransformer {
    
    enum Error: LocalizedError {
        
        case invalidString(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidString(let string):
                return "Can't convert string \"\(string)\" to date"
            }
        }
        
    }
    
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFormatter
    }()
    
    func string(from date: Date) -> String {
        return dateFormatter.string(from: date)
    }

    func date(from string: String) throws -> Date {
        guard let date = dateFormatter.date(from: string) else {
            throw Error.invalidString(string)
        }
        return date
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let string = value as? String else { return nil }
        return try? date(from: string)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let date = value as? Date else { return nil }
        return string(from: date)
    }
    
}
