//
//  NSAttributedString+Extension.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

extension NSAttributedString {

    public var attributes: [NSAttributedString.Key: Any] {
        return attributes(at: 0, effectiveRange: nil)
    }
    
    public func addingAttributes(_ attrs: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let range = NSRange(location: 0, length: length)
        let result = (mutableCopy() as! NSMutableAttributedString) // swiftlint:disable:this force_cast
        result.addAttributes(attrs, range: range)
        return result.copy() as! NSAttributedString // swiftlint:disable:this force_cast
    }
    
    public func attributizingOccurences(of substring: String, with attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let copy = mutableCopy() as! NSMutableAttributedString // swiftlint:disable:this force_cast
        copy.attributizedOccurences(of: substring, with: attributes)
        return copy.copy() as! NSAttributedString // swiftlint:disable:this force_cast
    }
    
    public func mapAttributes(in range: NSRange? = nil, options: NSAttributedString.EnumerationOptions = [], transform: (inout [NSAttributedString.Key: Any], NSRange) -> Void) -> NSAttributedString {
        var accumulator = [([NSAttributedString.Key: Any], NSRange)]()
        
        let range = range ?? NSRange(location: 0, length: string.count)
        enumerateAttributes(in: range, options: []) { attributes, range, _ in
            var attributes = attributes
            transform(&attributes, range)
            accumulator.append((attributes, range))
        }
        
        let copy = mutableCopy() as! NSMutableAttributedString // swiftlint:disable:this force_cast
        for (attributes, range) in accumulator {
            copy.setAttributes(attributes, range: range)
        }
        return copy.copy() as! NSAttributedString // swiftlint:disable:this force_cast
    }
    
    public func appending(_ attrString: NSAttributedString) -> NSAttributedString {
        let result = mutableCopy() as! NSMutableAttributedString // swiftlint:disable:this force_cast
        result.append(attrString)
        return result.copy() as! NSAttributedString // swiftlint:disable:this force_cast
    }
    
    public func appending(_ string: String) -> NSAttributedString {
        let result = mutableCopy() as! NSMutableAttributedString // swiftlint:disable:this force_cast
        result.append(NSAttributedString(string: string))
        return result.copy() as! NSAttributedString // swiftlint:disable:this force_cast
    }
    
}

extension NSMutableAttributedString {
    
    public func attributizedOccurences(of substring: String, with attributes: [NSAttributedString.Key: Any]) {
        var range = string.startIndex..<string.endIndex
        
        while true {
            guard let result = string.range(of: substring, options: [], range: range) else { break }
            addAttributes(attributes, range: NSRange(result, in: string))
            range = result.upperBound..<string.endIndex
        }
    }
    
}
