//
//  UIView+Extension.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit

public extension UIView.AutoresizingMask {
    
    public static var flexibleMargins: UIView.AutoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin]
    
    public static var flexibleDimensions: UIView.AutoresizingMask = [.flexibleWidth, .flexibleHeight]
    
}

public extension UIView {
    
    public func wobble() {
        wobble(duration: 0.25, amplitude: 10, frequency: 7)
    }
    
    private func wobble(duration: TimeInterval, amplitude: Double, frequency: Double) {
        let fr = layer.value(forKeyPath: "position.x") as! NSNumber // swiftlint:disable:this force_cast
        let values: [Double] = (0...100).map { i in
            let t = Double(i) / 100.0
            return fr.doubleValue + amplitude * (sin((Double.pi / 2) * t * frequency) / exp((Double.pi / 2) * t))
        }
        
        let animation = CAKeyframeAnimation(keyPath: "position.x")
        animation.values = values
        animation.duration = duration
        layer.add(animation, forKey: "wobble")
    }
    
    public func superview(with `class`: AnyClass?) -> UIView? {
        var view: UIView? = self
        
        while view?.superview != nil {
            view = view?.superview
            if let `class` = `class`, view?.isKind(of: `class`) != nil {
                break
            }
        }
        
        return view == self ? nil : view
    }
    
}
