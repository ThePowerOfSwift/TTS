//
//  Form.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

open class Form: NSObject {
    
    public func validateForInsert() throws {
        for propertyName in propertiesNamesIterator() {
            var value = self.value(forKey: propertyName) as AnyObject?
            try validateValue(&value, forKey: propertyName)
        }
    }
    
    public func isValidValue(forKey key: String) -> Bool {
        return error(forKey: key) == nil
    }
    
    public func error(forKey key: String) -> Error? {
        do {
            var value = self.value(forKey: key) as AnyObject?
            try validateValue(&value, forKey: key)
            return nil
        } catch {
            return error
        }
    }
    
    // Returns all errors
    public var errors: [Error] {
        return propertiesNamesIterator().compactMap { propertyName in
            guard propertyName != "errors" else { return nil }
            var value = self.value(forKey: propertyName) as AnyObject?
            do {
                try validateValue(&value, forKey: propertyName)
                return nil
            } catch {
                return error
            }
        }
    }
    
}
