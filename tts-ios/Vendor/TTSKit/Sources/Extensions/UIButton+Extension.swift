//
//  UIButton+Extension.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 28/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

extension UIButton {
    
    @objc(setBackgroundColor:forState:)
    public dynamic func setBackgroundColor(_ color: UIColor?, for state: UIControl.State) {
        if let color = color {
            let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
            let image = ImageDrawer.default.draw(BezierPathImage(fillColor: color), in: rect).resizableImage(withCapInsets: .zero)
            setBackgroundImage(image, for: state)
        } else {
            setBackgroundImage(nil, for: state)
        }
    }
    
}
