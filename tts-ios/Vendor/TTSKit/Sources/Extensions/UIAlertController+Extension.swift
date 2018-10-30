//
//  UIAlertController+Extension.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 19/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

extension UIAlertController {
    
    public var attributedTitle: NSAttributedString? {
        get {
            return value(forKey: "attributedTitle") as? NSAttributedString
        }
        set {
            setValue(newValue, forKey: "attributedTitle")
        }
    }

    public func setContentViewController(_ viewController: UIViewController?, preferredContentHeight: CGFloat? = nil) {
        if let preferredContentHeight = preferredContentHeight {
            viewController?.preferredContentSize.height = preferredContentHeight
        }
        setValue(viewController, forKey: "contentViewController")
    }

}
