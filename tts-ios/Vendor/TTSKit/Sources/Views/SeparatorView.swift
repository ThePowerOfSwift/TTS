//
//  SeparatorView.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 26/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit

public final class SeparatorView: UIView {
    
    // MARK: - Resizing Behaviour
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.height = UIScreen.main.px
        return size
    }
    
    // MARK: - Measuring in Constraint-Based Layout
    
    public override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height = UIScreen.main.px
        return size
    }
    
}
