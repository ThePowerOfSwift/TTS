//
//  BezierPathImage.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 26/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public struct BezierPathImage: Drawable, Equatable {
    
    public struct Stroke: Equatable {
        
        public enum Style: Equatable {
            
            case line
            
            /// Array of floating point values that contains the lengths (measured in points) of the line segments and gaps in the pattern. The values in the array alternate, starting with the first line segment length, followed by the first gap length, followed by the second line segment length, and so on
            ///
            /// The offset at which to start drawing the pattern, measured in points along the dashed-line pattern. For example, a phase value of 6 for the pattern 5-2-3-2 would cause drawing to begin in the middle of the first gap.
            case dash(pattern: [CGFloat], phase: CGFloat)
            
        }
        
        public var color: UIColor
        
        public var style: Style
        
        public var lineWidth: CGFloat
        
        public init(color: UIColor, style: Style = .line, lineWidth: CGFloat = 1) {
            self.color = color
            self.style = style
            self.lineWidth = lineWidth
        }
        
    }
    
    public var fillColor: UIColor
    
    public var stroke: Stroke?
    
    public var corners: UIRectCorner
    
    public var radius: CGFloat
    
    public var shadow: NSShadow?
    
    public init(fillColor: UIColor, stroke: Stroke? = nil, corners: UIRectCorner = .allCorners, radius: CGFloat = 0, shadow: NSShadow? = nil) {
        self.fillColor = fillColor
        self.stroke = stroke
        self.corners = corners
        self.radius = radius
        self.shadow = shadow
    }
    
    public func cacheIdentifier(forImageInRect rect: CGRect) -> String {
        return "\(String(describing: BezierPathImage.self)):\(rect):\(fillColor):\(String(describing: stroke)):\(corners):\(radius):\(String(describing: shadow))"
    }
    
    public func draw(in rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        
        fillColor.setFill()
        
        if let shadow = shadow {
            context.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: (shadow.shadowColor as? UIColor)?.cgColor)
        }
        
        if let stroke = stroke {
            context.translateBy(x: stroke.lineWidth / 2, y: stroke.lineWidth / 2)
            context.scaleBy(x: (rect.width - stroke.lineWidth) / rect.width, y: (rect.height - stroke.lineWidth) / rect.height)
        }
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        path.fill()
        
        if let stroke = stroke {
            switch stroke.style {
            case .line:
                () // do nothing
            case .dash(let pattern, let phase):
                var pattern = pattern
                path.setLineDash(&pattern, count: pattern.count, phase: phase)
            }
            path.lineWidth = stroke.lineWidth
            stroke.color.setStroke()
            path.stroke()
        }
        
        context.restoreGState()
    }
    
}
