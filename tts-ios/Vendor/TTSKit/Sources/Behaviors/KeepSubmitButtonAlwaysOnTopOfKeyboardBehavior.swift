//
//  KeepSubmitButtonAlwaysOnTopOfKeyboardBehavior.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 31/05/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation
import RxSwift

/// The behavior changes bottom inset of the submit button to make it appear always above keyboard.
///
/// In order to use this behavior you have to pin submit button's left, bottom, right edges to superview using autolayout constraints.
public final class KeepSubmitButtonAlwaysOnTopOfKeyboardBehavior {
    
    private let submitButton: UIButton
    private var observer: Disposable!
    
    public init(submitButton: UIButton) {
        self.submitButton = submitButton
        observer = KeyboardObserver.shared.addObserver(for: UIResponder.keyboardWillChangeFrameNotification, withinAnimation: { [weak self] in
            guard let superview = submitButton.superview else { return }
            UIView.performWithoutAnimation {
                superview.layoutIfNeeded()
            }
            let insetBottom = $0.frameEndBottomInset(in: superview)
            self?.updateLayout(insetBottom: insetBottom, in: superview)
            superview.layoutIfNeeded()
        })
    }
    
    /// Usefull to call on first layout pass to configure bottom inset with initial bottom layout margin value.
    public func layoutAtBottomGuide() {
        guard let superview = submitButton.superview else { return }
        updateLayout(insetBottom: 0, in: superview)
    }
    
    private func updateLayout(insetBottom: CGFloat, in superview: UIView) {
        guard let bottomSpace = submitButton.constraintsAffectingLayout(for: .vertical).first(where: {
            let isBottomSpace = $0.firstAttribute == .bottom && $0.secondAttribute == .bottom
            let isConnectedToSuperview = $0.firstItem?.isEqual(superview) ?? false || $0.secondItem?.isEqual(superview) ?? false
            return isBottomSpace && isConnectedToSuperview
        }) else { return }
        
        bottomSpace.constant = max(insetBottom, superview.layoutMargins.bottom)
    }
    
}
