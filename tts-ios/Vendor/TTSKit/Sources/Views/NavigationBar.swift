//
//  NavigationBar.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 26/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit

public final class NavigationBar: UINavigationBar {
    
    public enum Style {
        
        case transparent
        
        case barTintColor(UIColor)
        
    }
    
    public var shouldCleanTitleForBackBarButtonItem: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var shouldHideBackgroundImageSeparatorView: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        shadowImage = UIImage()
        isTranslucent = true
        backgroundColor = .clear
    }
    
    // MARK: - Laying out Subviews
    
    public override func layoutSubviews() {
        if shouldCleanTitleForBackBarButtonItem {
            items?.forEach {
                if $0.backBarButtonItem == nil {
                    $0.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                }
            }
        }
        
        super.layoutSubviews()
        
        if backgroundImage(for: .default) == nil, let backgroundView = subviews.first(where: { return String(describing: type(of: $0)).contains("Background") }) {
            if let separatorView = backgroundView.subviews.first(where: { return $0 is UIImageView }) {
                separatorView.isHidden = shouldHideBackgroundImageSeparatorView
            }
        }
    }
    
    // MARK: - Styling
    
    public var style: Style? {
        didSet {
            guard let style = style else {
                return
            }
            
            switch style {
            case .transparent:
                setBackgroundImage(UIImage(), for: .default)
            case .barTintColor(let color):
                barTintColor = color
            }
        }
    }
    
}
