//
//  NSObject+Extension.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import ObjectiveC

extension NSObject {
    
    public func propertiesNamesIterator() -> AnyIterator<String> {
        var count: UInt32 = 0
        let properties = class_copyPropertyList(type(of: self), &count)
        var i: Int = 0
        
        return AnyIterator {
            guard let properties = properties, i < Int(count) else { return nil }
            let name = property_getName(properties[i])
            let string = String(cString: name)
            i += 1
            return string
        }
    }
    
}
