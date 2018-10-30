//
//  FadeAnimator.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 16/03/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import UIKit

public final class FadeAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    public let isPresenting: Bool
    
    public init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.22
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        isPresenting ? animatePresentation(using: transitionContext) : animateDismissal(using: transitionContext)
    }
    
    private func animatePresentation(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toViewController = transitionContext.viewController(forKey: .to),
            let toView = transitionContext.view(forKey: .to) else {
                transitionContext.completeTransition(false)
                return
        }
        let containerView = transitionContext.containerView
        let toViewFinalFrame = transitionContext.finalFrame(for: toViewController)
        let duration = transitionDuration(using: transitionContext)
        
        toView.alpha = 0
        toView.frame = toViewFinalFrame
        containerView.addSubview(toView)
        
        UIView.animate(withDuration: duration, delay: 0, options: [], animations: {
            toView.alpha = 1
        }, completion: { _ in
            let didComplete = !transitionContext.transitionWasCancelled
            
            if !didComplete {
                toView.removeFromSuperview()
            }
            
            transitionContext.completeTransition(didComplete)
        })
    }
    
    private func animateDismissal(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromView = transitionContext.view(forKey: .from) else {
                transitionContext.completeTransition(false)
                return
        }
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: 0, options: [], animations: {
            fromView.alpha = 0
        }, completion: { _ in
            let didComplete = !transitionContext.transitionWasCancelled
            
            if didComplete {
                fromView.removeFromSuperview()
            }
            
            transitionContext.completeTransition(didComplete)
        })
    }
    
}
