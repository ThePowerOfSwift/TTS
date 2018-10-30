//
//  DimmingPresentationController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 11/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit

final class DimmingPresentationController: UIPresentationController {
    
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(blurViewTapped))
        blurView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        guard type(of: container) === type(of: presentedViewController) else { return }
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }

        var height = presentedViewController.preferredContentSize.height > 0 ? min(presentedViewController.preferredContentSize.height, containerView.bounds.height) : containerView.bounds.height
        if #available(iOS 11.0, *) {
            height += containerView.safeAreaInsets.bottom
        }

        let y = containerView.bounds.height - height
        
        return CGRect(x: 0, y: y, width: containerView.bounds.width, height: height)
    }
    
    override func presentationTransitionWillBegin() {
        // Add a custom dimming view behind the presented view controller's view
        guard let containerView = containerView else { return }
        blurView.autoresizingMask = .flexibleDimensions
        blurView.frame = containerView.bounds
        containerView.insertSubview(blurView, at: 0)
        
        // Use the transition coordinator to set up the animations.
        guard let transitionCoordinator = presentingViewController.transitionCoordinator else { return }
        blurView.alpha = 0
        transitionCoordinator.animate(alongsideTransition: { [weak self] _ in
            self?.blurView.alpha = 1
        }, completion: nil)
        
        presentedView?.layer.cornerRadius = 8
    }
    
    override func dismissalTransitionWillBegin() {
        guard let transitionCoordinator = presentingViewController.transitionCoordinator else { return }
        
        transitionCoordinator.animate(alongsideTransition: { [weak self] _ in
            self?.blurView.alpha = 0
        }, completion: { [weak self] _ in
            self?.blurView.removeFromSuperview()
        })
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        // Remove the dimming view if the presentation was aborted.
        if !completed {
            blurView.removeFromSuperview()
        }
    }
    
    // MARK: - Dismissing
    
    @objc
    private func blurViewTapped() {
        presentingViewController.dismiss(animated: IsAnimationAllowed(), completion: nil)
    }
    
}
