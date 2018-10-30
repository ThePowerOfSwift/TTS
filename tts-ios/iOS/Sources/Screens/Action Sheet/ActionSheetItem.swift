//
//  ActionSheetItem.swift
//  tts
//
//  Created by Dmitry Nesterenko on 16/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit

protocol ActionSheetItem {
    
}

public class ActionSheetAction: ActionSheetItem {
    
    public enum Style {
        case cancel
        case `default`
        case destructive
        case custom(textColor: UIColor)
    }
    
    public var title: String
    public var style: Style
    public var handler: ((ActionSheetAction) -> Void)?
    
    public init(title: String, style: Style = .default, handler: ((ActionSheetAction) -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
    
}

public class AlertImage: ActionSheetItem {
    
    public var image: UIImage
    public var layoutMargins: UIEdgeInsets
    
    public init(image: UIImage, layoutMargins: UIEdgeInsets) {
        self.image = image
        self.layoutMargins = layoutMargins
    }
    
}

public class AlertView: ActionSheetItem {
    
    public let view: UIView
    public let layoutMargins: UIEdgeInsets
    
    public init(view: UIView, layoutMargins: UIEdgeInsets) {
        self.view = view
        self.layoutMargins = layoutMargins
    }
    
}
