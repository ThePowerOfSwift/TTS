//
//  NSParagraphStyle+Extension.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

extension NSParagraphStyle {
    
    public func with(transformer: (NSMutableParagraphStyle) -> Void) -> NSParagraphStyle {
        let copy = mutableCopy() as! NSMutableParagraphStyle // swiftlint:disable:this force_cast
        transformer(copy)
        return copy.copy() as! NSParagraphStyle // swiftlint:disable:this force_cast
    }
    
}
