//
//  UIColor+Extension.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit

extension UIColor {
    
    /// Convenience initialiser for creating UIColor objects with RGB values ranging from 0-255.
    ///
    /// - parameters:
    ///     - r: Int representing the red component of the color ranging from 0 to 255.
    ///     - g: Int representing the green component of the color ranging from 0 to 255.
    ///     - b: Int representing the blue component of the color ranging from 0 to 255.
    ///     - a: Int representing the alpha component of the color ranging from 0 to 1.
    ///
    /// - returns: UIColor representing the RGB values with alpha set to full 1.
    public convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1) {
        self.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: a)
    }
    
    /// Convenience initialiser for creating UIColor objects with a hex number representation
    /// (e.g. 0x4285F4 or 0x4285F450). If no alpha component given it defaults to 0xFF.
    /// - parameters:
    ///     - hex: Int representing the red, green and blue components of the color.
    ///
    /// - returns: UIColor representing the hex value provided.
    public convenience init(hex: UInt32) {
        var bytesToShift = 8 * 2
        let alphaExists = hex > 0xffffff
        
        // If there's an alpha component to shift.
        if alphaExists {
            bytesToShift += 8
        }
        
        let red = (hex >> bytesToShift) & 0xff
        bytesToShift -= 8
        let green = (hex >> bytesToShift) & 0xff
        bytesToShift -= 8
        let blue = (hex >> bytesToShift) & 0xff
        let alpha: CGFloat
        if alphaExists {
            let alphaInt = hex & 0xff
            alpha = CGFloat(alphaInt) / 255.0
        } else {
            alpha = 1
        }
        
        self.init(r: Int(red), g: Int(green), b: Int(blue), a: alpha)
    }
    
    public func brightening(by d: CGFloat) -> UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: red + d, green: green + d, blue: blue + d, alpha: alpha)
        }
        
        var white: CGFloat = 0
        if getWhite(&white, alpha: &alpha) {
            return UIColor(white: white + d, alpha: alpha)
        }
        
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: hue, saturation: saturation, brightness: brightness + d, alpha: alpha)
        }
        
        fatalError()
    }
    
}
