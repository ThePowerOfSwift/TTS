//
//  StarImage.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 21/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public final class StarImage: Drawable {
    
    public let fillColor: UIColor?
    public let stroke: BezierPathImage.Stroke?
    public let lineJoin: CGLineJoin?
    public let numberOfCorners: Int
    public let proportion: CGFloat
    public let startAngle: CGFloat
    
    public init(fillColor: UIColor, stroke: BezierPathImage.Stroke? = nil, lineJoin: CGLineJoin? = nil, numberOfCorners: Int, proportion: CGFloat, startAngle: CGFloat) {
        self.fillColor = fillColor
        self.stroke = stroke
        self.lineJoin = lineJoin
        self.numberOfCorners = numberOfCorners
        self.proportion = proportion
        self.startAngle = startAngle
    }
    
    public func cacheIdentifier(forImageInRect rect: CGRect) -> String {
        return "\(String(describing: type(of: self))):\(rect):\(String(describing: fillColor)):\(String(describing: stroke)):\(String(describing: lineJoin)):\(numberOfCorners):\(proportion):\(startAngle)"
    }
    
    public func draw(in rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()
        
        if let stroke = stroke {
            context.translateBy(x: stroke.lineWidth / 2, y: stroke.lineWidth / 2)
            context.scaleBy(x: (rect.width - stroke.lineWidth) / rect.width, y: (rect.height - stroke.lineWidth) / rect.height)
        }
        
        fillColor?.setFill()
        
        if let stroke = stroke {
            switch stroke.style {
            case .line:
                () // do nothing
            case .dash(let pattern, let phase):
                context.setLineDash(phase: phase, lengths: pattern)
            }
            context.setLineWidth(stroke.lineWidth)
            stroke.color.setStroke()
        }
        
        if let lineJoin = lineJoin {
            context.setLineJoin(lineJoin)
        }
        
        let angle = (CGFloat.pi * 2) / CGFloat(2 * numberOfCorners) // twice as many sides
        let width = rect.width
        let height = rect.height
        
        let w = width / 2
        let h = height / 2
        let cx = rect.midX
        let cy = rect.midY
        
        context.move(to: CGPoint(x: cx + w * cos(startAngle), y: cy + h * sin(startAngle)))
        
        for i in 1..<2 * numberOfCorners {
            let dw: CGFloat
            let dh: CGFloat
            
            if i % 2 == 1 {
                dw = w * proportion
                dh = h * proportion
            } else {
                dw = w
                dh = h
            }
            
            context.addLine(to: CGPoint(x: cx + dw * cos(startAngle + angle * CGFloat(i)), y: cy + dh * sin(startAngle + angle * CGFloat(i))))
        }
        
        context.closePath()
        
        context.fillPath()
        if stroke != nil {
            context.strokePath()
        }
        
        context.restoreGState()
    }
    
}
