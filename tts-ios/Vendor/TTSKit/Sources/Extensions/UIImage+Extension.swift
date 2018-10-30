//
//  UIImage+Extension.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import CoreGraphics

public extension UIImage {
    
    public enum Scale: Int {
        
        case fill
        
        case aspectFit
        
        case aspectFill
        
        func drawRect(currentSize: CGSize, canvasSize: CGSize) -> CGRect {
            switch self {
                
            case .fill:
                return CGRect(origin: .zero, size: canvasSize)
                
            case .aspectFill:
                let imageAspectRatio = currentSize.width / currentSize.height
                let canvasAspectRatio = canvasSize.width / canvasSize.height
                
                var resizeFactor: CGFloat
                
                if imageAspectRatio > canvasAspectRatio {
                    resizeFactor = canvasSize.height / currentSize.height
                } else {
                    resizeFactor = canvasSize.width / currentSize.width
                }
                
                let scaledSize = CGSize(width: currentSize.width * resizeFactor, height: currentSize.height * resizeFactor)
                let origin = CGPoint(x: (canvasSize.width - scaledSize.width) / 2.0, y: (canvasSize.height - scaledSize.height) / 2.0)
                
                return CGRect(origin: origin, size: scaledSize)
                
            case .aspectFit:
                let imageAspectRatio = currentSize.width / currentSize.height
                let canvasAspectRatio = canvasSize.width / canvasSize.height
                
                var resizeFactor: CGFloat
                
                if imageAspectRatio > canvasAspectRatio {
                    resizeFactor = canvasSize.width / currentSize.width
                } else {
                    resizeFactor = canvasSize.height / currentSize.height
                }
                
                let scaledSize = CGSize(width: currentSize.width * resizeFactor, height: currentSize.height * resizeFactor)
                let origin = CGPoint(x: (canvasSize.width - scaledSize.width) / 2.0, y: (canvasSize.height - scaledSize.height) / 2.0)
                
                return CGRect(origin: origin, size: scaledSize)
                
            }
        }
        
    }
    
    /// Creates image with specified size using block for drawing content
    public static func image(size: CGSize, actions: (UIGraphicsImageRendererContext) -> Void) -> UIImage {
        let format: UIGraphicsImageRendererFormat
        if #available(iOS 11.0, *) {
            format = UIGraphicsImageRendererFormat.preferred()
        } else {
            format = UIGraphicsImageRendererFormat.default()
        }
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image(actions: actions)
    }
    
    public func scaling(to size: CGSize, scale: Scale) -> UIImage? {
        assert(size.width > 0 && size.height > 0, "You cannot safely scale an image to a zero width or height")
        
        return UIImage.image(size: size, actions: { _ in
            let drawRect = scale.drawRect(currentSize: self.size, canvasSize: size)
            return self.draw(in: drawRect)
        })
    }
    
}
