//
//  UIScrollView+Extension.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 07/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    public var boundsSizeWithContentInsetExcluded: CGSize {
        let width: CGFloat
        let height: CGFloat
        
        if #available(iOS 11.0, *) {
            width = bounds.width - adjustedContentInset.left - adjustedContentInset.right
            height = bounds.height - adjustedContentInset.top - adjustedContentInset.bottom
        } else {
            width = bounds.width - contentInset.left - contentInset.right
            height = bounds.height - contentInset.top - contentInset.bottom
        }
        
        return CGSize(width: width, height: height)
    }
    
}
