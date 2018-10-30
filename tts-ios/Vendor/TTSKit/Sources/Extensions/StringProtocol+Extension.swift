//
//  StringProtocol+Extension.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 25/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

extension StringProtocol {
    
    public func dropPrefix(_ prefix: String) -> Self.SubSequence {
        if hasPrefix(prefix) {
            return dropFirst(prefix.count)
        } else {
            return dropFirst(0)
        }
    }
    
    public func dropSuffix(_ suffix: String) -> Self.SubSequence {
        if hasSuffix(suffix) {
            return dropLast(suffix.count)
        } else {
            return dropLast(0)
        }
    }
    
}
