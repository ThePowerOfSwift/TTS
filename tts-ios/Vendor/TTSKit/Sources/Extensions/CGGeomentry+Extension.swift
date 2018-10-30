//
//  CGGeomentry+Extension.swift
//  tts
//
//  Created by Dmitry Nesterenko on 26/09/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import CoreGraphics

extension CGRect {
    
    /// Rect center relative to rect's origin
    public var center: CGPoint {
        return CGPoint(x: width / 2, y: height / 2)
    }
    
    /// Rect center in absolute coordinates
    public var middle: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
    
}

extension CGSize {
    
    public var minimumDimension: CGFloat {
        return min(width, height)
    }
    
    public var maximumDimension: CGFloat {
        return max(width, height)
    }
    
}
