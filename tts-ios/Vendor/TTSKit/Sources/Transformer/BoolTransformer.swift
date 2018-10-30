//
//  BoolTransformer.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 22/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

final class BoolTransformer: ValueTransformer {
    
    enum Error: Swift.Error {
        case invalidValue
    }
    
    func boolValue(fromString string: String) throws -> Bool {
        switch string {
        case "true", "1":
            return true
        case "false", "0":
            return false
        default:
            throw Error.invalidValue
        }
    }

    func boolValue(fromAny value: Any?) throws -> Bool {
        if let string = value as? String {
            return try boolValue(fromString: string)
        } else if let int = value as? Int {
            return try boolValue(fromInt: int)
        } else if let bool = value as? Bool {
            return bool
        } else {
            throw Error.invalidValue
        }
    }

    func boolValue(fromInt int: Int) throws -> Bool {
        return int > 0
    }

    override func transformedValue(_ value: Any?) -> Any? {
        return try? boolValue(fromAny: value)
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return false
    }
    
}
