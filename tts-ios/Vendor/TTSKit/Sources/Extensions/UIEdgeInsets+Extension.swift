//
//  UIEdgeInsets+Extension.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 16/03/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public extension UIEdgeInsets {
    
    public init(insets: CGFloat) {
        self.init(top: insets, left: insets, bottom: insets, right: insets)
    }
    
    public init(offset: UIOffset) {
        self.init(horizontal: offset.horizontal, vertical: offset.vertical)
    }
    
    public init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
    
}
