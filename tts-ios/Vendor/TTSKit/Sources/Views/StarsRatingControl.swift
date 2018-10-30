//
//  StarsRatingControl.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 21/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import UIKit

public final class StarsRatingControl: UIControl {
    
    public var proportion: CGFloat = 0.43 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var interitemSpacing: CGFloat = 8 {
        didSet {
            setNeedsDisplay()
        }
    }

    public var starInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4) {
        didSet {
            setNeedsDisplay()
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
        contentMode = .redraw
    }
    
    // MARK: - Managing Stars Color
    
    private var starsFillColors = [UIControl.State.normal.rawValue: UIColor.lightGray, UIControl.State.selected.rawValue: UIColor.red]
    private var starsBorderColors = [UInt: UIColor]()
    
    public func setStarsFillColor(_ color: UIColor, forState state: UIControl.State) {
        starsFillColors[state.rawValue] = color
        setNeedsDisplay()
    }
    
    public func starsFillColor(forState state: UIControl.State) -> UIColor? {
        return starsFillColors[state.rawValue]
    }

    public func setStarsBorderColor(_ color: UIColor, forState state: UIControl.State) {
        starsBorderColors[state.rawValue] = color
        setNeedsDisplay()
    }
    
    public func starsBorderColor(forState state: UIControl.State) -> UIColor? {
        return starsBorderColors[state.rawValue]
    }
    
    // MARK: - Managing Number Of Stars
    
    public var numberOfStars: Int = 5 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var numberOfSelectedStars: Int = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // MARK: - Drawing and Updating the View
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let numberOfStars = max(0, self.numberOfStars)
        let numberOfSelectedStars = min(max(0, self.numberOfSelectedStars), numberOfStars)
        let fillColorNormal = starsFillColor(forState: .normal)
        let fillColorSelected = starsFillColor(forState: .selected)
        
        for i in 0..<numberOfStars {
            let width = (bounds.width - interitemSpacing * CGFloat(numberOfStars - 1)) / CGFloat(numberOfStars)
            let x = CGFloat(i) * (width + interitemSpacing)
            let starRect = CGRect(x: x, y: 0, width: width, height: bounds.height)

            let fillColor = (i < numberOfSelectedStars ? fillColorSelected : fillColorNormal) ?? .clear
            
            let star = StarImage(fillColor: fillColor, stroke: nil, numberOfCorners: 5, proportion: proportion, startAngle: -CGFloat.pi / 2)
            let imageRect = CGRect(x: 0, y: 0, width: starRect.width - starInsets.left - starInsets.right, height: starRect.width - starInsets.left - starInsets.right)
            let image = ImageDrawer.default.draw(star, in: imageRect)
            image.draw(in: CGRect(x: x + starInsets.left, y: bounds.midY - image.size.width / 2, width: image.size.width, height: image.size.height))
        }
    }
    
    // MARK: - Tracking Touches and Redrawing Controls
    
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let result = super.beginTracking(touch, with: event)
        handleTouch(touch)
        return result
    }
    
    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let result = super.continueTracking(touch, with: event)
        handleTouch(touch)
        return result
    }
    
    private func handleTouch(_ touch: UITouch) {
        guard numberOfStars > 0 else { return }

        let x = touch.location(in: self).x
        let itemWidth = bounds.width / CGFloat(numberOfStars)
        
        if 0 <= x && x <= bounds.width {
            let proposedNumberOfSelectedStars: Int
            if x / itemWidth < 0.5 {
                proposedNumberOfSelectedStars = 0
            } else {
                proposedNumberOfSelectedStars = Int(ceil(x / itemWidth))
            }
            
            if numberOfSelectedStars != proposedNumberOfSelectedStars {
                numberOfSelectedStars = proposedNumberOfSelectedStars
                sendActions(for: .valueChanged)
            }
        }
    }
    
}
