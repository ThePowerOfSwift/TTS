//
//  UIMotionEffectGroup+Extension.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 16/03/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import UIKit

public extension UIMotionEffectGroup {
    
    public convenience init(tiltOffset: UIOffset) {
        self.init()
        
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -tiltOffset.horizontal
        horizontal.maximumRelativeValue = tiltOffset.horizontal
        
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -tiltOffset.vertical
        vertical.maximumRelativeValue = tiltOffset.vertical
        
        motionEffects = [horizontal, vertical]
    }
    
}
