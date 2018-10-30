//
//  UIFont+Extension.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 13/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

extension UIFont {
    
    /// Helper method to create a UIFont with updated attributes applied to the UIFontDescriptor
    ///
    /// - parameter attributes: The new attributes to apply to the fontDescriptor
    ///
    /// - returns: A UIFont object with the new attributes appended to the receivers fontDescriptor
    public func addingAttributes(_ attributes: [UIFontDescriptor.AttributeName: Any]) -> UIFont {
        return UIFont(descriptor: fontDescriptor.addingAttributes(attributes), size: pointSize)
    }
    
    public func withSymbolicTraits(_ symbolicTraits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
        guard let descriptor = fontDescriptor.withSymbolicTraits(symbolicTraits) else { return nil }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
    
}
