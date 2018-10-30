//
//  Drawable.swift
//  tts
//
//  Created by Dmitry Nesterenko on 20/07/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public protocol Drawable {
    
    func cacheIdentifier(forImageInRect rect: CGRect) -> String

    func draw(in rect: CGRect)
    
}
