//
//  MessageView.swift
//  tts
//
//  Created by Dmitry Nesterenko on 16/05/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import SwiftMessages

private let kLabelInsetX: CGFloat = 12
private let kLabelInsetY: CGFloat = 8

class MessageView: UIView, MarginAdjustable {
    
    enum Style {
        case blue
        case black
    }
    
    private let label = UILabel()
    
    var style: Style = .blue {
        didSet {
            updateStyle()
        }
    }
    
    private func updateStyle() {
        switch style {
        case .blue:
            backgroundColor = UIColor(r: 17, g: 128, b: 202)
        case .black:
            backgroundColor = UIColor(r: 19, g: 21, b: 25)
        }
    }
    
    var text: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }
    
    convenience init(text: String, style: Style = .blue) {
        self.init(frame: .zero)
        self.text = text
        self.style = style
        updateStyle()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.font = UIFont.systemFont(ofSize: 17, weight: .light)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.autoresizingMask = .flexibleDimensions
        addSubview(label)
        
        updateStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Laying out Subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labelTopOffset = statusBarOffset + bounceAnimationOffset
        label.frame = bounds.insetBy(dx: kLabelInsetX, dy: kLabelInsetY).offsetBy(dx: 0, dy: labelTopOffset / 2).insetBy(dx: 0, dy: labelTopOffset / 2)
    }
    
    // MARK: - Resizing Behaviour
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: height(for: size.width))
    }
    
    private func height(for width: CGFloat) -> CGFloat {
        return safeAreaTopOffset + bounceAnimationOffset
    }
    
    // MARK: - Measuring in Auto Layout
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width, height: height(for: size.width))
    }
    
    // MARK: - Margin Adgusting
    
    var bounceAnimationOffset: CGFloat = BaseView().bounceAnimationOffset {
        didSet {
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }
    
    var statusBarOffset: CGFloat = 0 {
        didSet {
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }
    
    var safeAreaTopOffset: CGFloat = 0 {
        didSet {
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }
    
    var safeAreaBottomOffset: CGFloat = 0 {
        didSet {
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }
    
}
