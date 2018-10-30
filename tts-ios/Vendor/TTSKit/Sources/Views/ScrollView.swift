//
//  ScrollView.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit

class ScrollView: UIScrollView {
    
    // MARK: Managing Scrolling
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl {
            return true
        } else {
            return super.touchesShouldCancel(in: view)
        }
    }
    
}
