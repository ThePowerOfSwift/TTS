//
//  TableViewCollectionViewCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 31/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

let TableViewCollectionViewCellAutomaticSeparatorInset: UIEdgeInsets = UIEdgeInsets(top: -1, left: -1, bottom: -1, right: -1) // swiftlint:disable:this prefixed_toplevel_constant

/// A collection view cell that is configured to have separator view and selection background to be the same as in UITableViewCell
class TableViewCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Separator View
    
    private let separatorView = SeparatorView()
    
    var separatorInset: UIEdgeInsets = TableViewCollectionViewCellAutomaticSeparatorInset {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    var separatorColor: UIColor = UIColor(white: 151 / 255.0, alpha: 1) {
        didSet {
            updateSeparatorColor()
        }
    }
    
    private func updateSeparatorColor() {
        separatorView.backgroundColor = separatorColor
    }
    
    var separatorStyle: UITableViewCell.SeparatorStyle = .singleLine {
        didSet {
            updateSeparatorStyle()
        }
    }
    
    private func updateSeparatorStyle() {
        separatorView.isHidden = separatorStyle == .none
    }
    
    /// Helper method to allow inset configuration at IB
    @IBInspectable
    var separatorInsetLeft: CGFloat = 0 {
        didSet {
            separatorInset.left = separatorInsetLeft
        }
    }
    
    // MARK: - Selection
    
    private let systemSelectedBackgroundView = UIView()
    
    var selectionStyle: UITableViewCell.SelectionStyle = .default {
        didSet {
            updateSelectionStyle()
        }
    }
    
    private func updateSelectionStyle() {
        systemSelectedBackgroundView.backgroundColor = selectionStyle.color
        setNeedsLayout()
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        separatorView.autoresizingMask = .flexibleWidth
        
        updateSelectionStyle()
        updateSeparatorColor()
        updateSeparatorStyle()
    }
    
    // MARK: - Laying out Subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let separatorViewHeight = separatorView.sizeThatFits(.zero).height
        let separatorViewLeftSpace = TableViewCollectionViewCell.leadingSeparatorInset(forCell: self, separatorInset: separatorInset)
        separatorView.frame = CGRect(x: separatorViewLeftSpace, y: bounds.height - separatorViewHeight, width: bounds.width - separatorInset.left - separatorInset.right, height: separatorViewHeight)
        addSubview(separatorView)
        
        // apply system selection
        if selectionStyle == .none {
            if selectedBackgroundView == systemSelectedBackgroundView {
                selectedBackgroundView = nil
            }
        } else {
            if selectedBackgroundView == nil {
                selectedBackgroundView = systemSelectedBackgroundView
            }
        }
    }
    
    static func leadingSeparatorInset(forCell cell: UICollectionViewCell, separatorInset: UIEdgeInsets) -> CGFloat {
        return (separatorInset == TableViewCollectionViewCellAutomaticSeparatorInset) ? cell.layoutMargins.left + 8 : separatorInset.left
    }
    
    // MARK: - Managing Cell Selection and Highlighting

    override var isHighlighted: Bool {
        didSet {
            let animated = UIView.inheritedAnimationDuration > 0
            setHighlighted(isHighlighted, animated: animated)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            let animated = UIView.inheritedAnimationDuration > 0
            setSelected(isSelected, animated: animated)
        }
    }
    
    func setSelected(_ selected: Bool, animated: Bool) {
        updateSelectionAndHighlighting(animated: animated)
    }
    
    func setHighlighted(_ highlighted: Bool, animated: Bool) {
        updateSelectionAndHighlighting(animated: animated)
    }
    
    private func updateSelectionAndHighlighting(animated: Bool) {
        // do nothing
    }
    
}

extension TableViewCollectionViewCell {
    
    func apply(background: BezierPathImage?) {
        if let background = background {
            if background.corners.rawValue == 0 {
                backgroundColor = background.fillColor
            } else {
                backgroundColor = nil
                
                let backgroundImage = BezierPathImage(fillColor: background.fillColor, corners: background.corners, radius: background.radius)
                backgroundView = UIImageView(image: ImageDrawer.default.draw(backgroundImage, in: bounds).resizableImage(withCapInsets: UIEdgeInsets(insets: backgroundImage.radius)))
                
                if let selectionColor = selectionStyle.color {
                    let selectedBackgroundImage = BezierPathImage(fillColor: selectionColor, corners: background.corners, radius: background.radius)
                    selectedBackgroundView = UIImageView(image: ImageDrawer.default.draw(selectedBackgroundImage, in: bounds).resizableImage(withCapInsets: UIEdgeInsets(insets: selectedBackgroundImage.radius)))
                }
            }
        } else {
            backgroundColor = nil
        }
    }
    
}
