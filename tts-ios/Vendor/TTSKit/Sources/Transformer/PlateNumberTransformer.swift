//
//  PlateNumberTransformer.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 11/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

final class PlateNumberTransformer: ValueTransformer {
    
    enum Error: Swift.Error {
        case invalidPlateNumberFormat
    }
    
    func plateNumberFromString(for string: String) throws -> PlateNumber {
        guard let result = PlateNumber(rawValue: string) else {
            throw Error.invalidPlateNumberFormat
        }
        
        return result
    }
    
    func stringFromPlateNumber(_ value: PlateNumber) -> String {
        return value.rawValue
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let string = value as? String else { return nil }
        return try? plateNumberFromString(for: string)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let plateNumber = value as? PlateNumber else { return nil }
        return stringFromPlateNumber(plateNumber)
    }
    
}
