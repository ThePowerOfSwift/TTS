//
//  UIScreen+Extension.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit

extension UIScreen {
    
    public var px: CGFloat {
        return max(0.5, 1 / scale)
    }
    
}
