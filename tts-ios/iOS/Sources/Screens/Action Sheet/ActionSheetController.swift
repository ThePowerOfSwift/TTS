//
//  CallbackViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 16/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

private let kLayoutMarginsHorizontal: CGFloat = 16

private enum Layout {
    case centerHorizontaly
    case pinToEdges
}

private func WrapViewInContainerViewAndAddToStackView(_ stackView: UIStackView, containerView: UIView, subview: UIView, layoutMargins: UIEdgeInsets, layout: Layout) {
    let layoutMarginsView = UIView(frame: containerView.bounds)
    layoutMarginsView.translatesAutoresizingMaskIntoConstraints = false
    layoutMarginsView.layoutMargins = layoutMargins
    layoutMarginsView.addSubview(subview)
    containerView.addSubview(layoutMarginsView)
    
    // pin layout margins view to container view edges
    layoutMarginsView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
    layoutMarginsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
    layoutMarginsView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    layoutMarginsView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
    
    switch layout {
    case .centerHorizontaly:
        // center subview horizontally
        subview.topAnchor.constraint(equalTo: layoutMarginsView.layoutMarginsGuide.topAnchor).isActive = true
        subview.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsView.layoutMarginsGuide.leadingAnchor).isActive = true
        subview.bottomAnchor.constraint(equalTo: layoutMarginsView.layoutMarginsGuide.bottomAnchor).isActive = true
        subview.trailingAnchor.constraint(lessThanOrEqualTo: layoutMarginsView.layoutMarginsGuide.trailingAnchor).isActive = true
        subview.centerXAnchor.constraint(equalTo: layoutMarginsView.centerXAnchor, constant: 0).isActive = true
    case .pinToEdges:
        // pin subview to layout margins view guides
        subview.topAnchor.constraint(equalTo: layoutMarginsView.layoutMarginsGuide.topAnchor).isActive = true
        subview.leadingAnchor.constraint(equalTo: layoutMarginsView.layoutMarginsGuide.leadingAnchor).isActive = true
        subview.bottomAnchor.constraint(equalTo: layoutMarginsView.layoutMarginsGuide.bottomAnchor).isActive = true
        subview.rightAnchor.constraint(equalTo: layoutMarginsView.layoutMarginsGuide.rightAnchor).isActive = true
    }
}

final class ActionSheetController: UIViewController, ErrorPresenting, UIViewControllerTransitioningDelegate {
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var scrollContentView: UIView!
    @IBOutlet private var scrollContentViewHeight: NSLayoutConstraint!
    @IBOutlet private var contentView: UIView!
    
    private var stackView = UIStackView()
    private let separatorContainerView = UIView()
    private let buttonsContainerView = UIView()
    
    var preferredAction: ActionSheetAction?
    
    deinit {
        setKeyboardNotificationsObservationEnabled(false)
    }
    
    convenience init(title: String?, message: String?) {
        self.init(nibName: nil, bundle: nil)
        self.title = title
        self.message = message
        
        setKeyboardNotificationsObservationEnabled(true)
        transitioningDelegate = self
        modalPresentationStyle = .custom
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // rounded corners background image
        let imageView = UIImageView(frame: contentView.bounds)
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let image = BezierPathImage(fillColor: UIColor(r: 37, g: 42, b: 57), corners: [.topLeft, .topRight], radius: 13)
        imageView.image = ImageDrawer.default.draw(image, in: CGRect(x: 0, y: 0, width: image.radius * 2, height: image.radius * 2))
            .resizableImage(withCapInsets: UIEdgeInsets(top: image.radius, left: image.radius, bottom: image.radius, right: image.radius))
        contentView.addSubview(imageView)
        
        // content views are managed by a stack view
        stackView.frame = contentView.bounds
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.layoutMargins = UIEdgeInsets(top: 32, left: 0, bottom: 0, right: 0)
        for containerView in [imageContainerView, titleContainerView, messageContainerView, contentViewControllerContainerView, separatorContainerView, buttonsContainerView] {
            containerView.layoutMargins = .zero
            containerView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(containerView)
        }
        contentView.addSubview(stackView)

        // build arranged subviews and calculate stackview's height
        insertArrangedSubviewsToStackView()
        
        // pin stackview's bounds to superview + flexible width + fixed height
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    }
    
    // MARK: - Responding to View Events
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.performWithoutAnimation {
            updateScrollViewContentSizeAndInsetsIfNeeded()
        }
    }
    
    // MARK: - Configuring the View’s Layout Behavior
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateScrollViewContentSizeAndInsetsIfNeeded()
    }
    
    private func updateScrollViewContentSizeAndInsetsIfNeeded() {
        // top inset
        let adjustedTopInset: CGFloat
        if #available(iOS 11, *) {
            adjustedTopInset = scrollView.safeAreaInsets.top
        } else {
            adjustedTopInset = topLayoutGuide.length
        }
        
        // bottom inset
        var adjustedBottomInset = keyboardBottomInset
        if #available(iOS 11, *), adjustedBottomInset > scrollView.safeAreaInsets.bottom {
            // Ignore safeAreaInsets when keyboard is visible on screen
            adjustedBottomInset -= scrollView.safeAreaInsets.bottom
        }
        
        // adjusted content inset
        let adjustedContentInset: UIEdgeInsets
        if #available(iOS 11, *) {
            adjustedContentInset = scrollView.adjustedContentInset
        } else {
            adjustedContentInset = scrollView.contentInset
        }
        
        // change content inset if needed
        if adjustedContentInset.top != adjustedTopInset || adjustedContentInset.bottom != adjustedBottomInset {
            if #available(iOS 11, *) {
                scrollView.contentInset = UIEdgeInsets(top: adjustedTopInset - adjustedContentInset.top, left: scrollView.contentInset.left, bottom: adjustedBottomInset - adjustedContentInset.bottom, right: scrollView.contentInset.right)
            } else {
                scrollView.contentInset = UIEdgeInsets(top: adjustedTopInset, left: scrollView.contentInset.left, bottom: adjustedBottomInset, right: scrollView.contentInset.right)
            }
            scrollView.scrollIndicatorInsets = scrollView.contentInset
        }
        
        let contentViewHeightConstant = -adjustedTopInset - adjustedBottomInset
        if scrollContentViewHeight.constant != contentViewHeightConstant {
            scrollContentViewHeight.constant = contentViewHeightConstant
            view.layoutIfNeeded()
            scrollView.flashScrollIndicators()
        }
    }
    
    // MARK: - Managing the Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Configuring Image View
    
    private let imageContainerView = UIView()
    private(set) var image: AlertImage?
    
    func setImage(_ image: UIImage) {
        self.image = AlertImage(image: image, layoutMargins: .zero)
        if isViewLoaded {
            updateImageView()
        }
    }
    
    private func updateImageView() {
        if let image = image {
            imageContainerView.isHidden = false
            stackView.updateConstraintsIfNeeded() // force remove height constraint
            
            if let imageView = imageContainerView.subviews.first?.subviews.first as? UIImageView {
                imageView.image = image.image
            } else {
                let imageView = UIImageView(image: image.image)
                imageView.translatesAutoresizingMaskIntoConstraints = false
                WrapViewInContainerViewAndAddToStackView(stackView, containerView: imageContainerView, subview: imageView, layoutMargins: UIEdgeInsets(top: 0, left: kLayoutMarginsHorizontal, bottom: 11, right: kLayoutMarginsHorizontal), layout: .centerHorizontaly)
            }
        } else {
            imageContainerView.subviews.forEach {$0.removeFromSuperview()}
            imageContainerView.isHidden = true
        }
    }
    
    // MARK: - Configuring Title
    
    private let titleContainerView = UIView()
    
    override var title: String? {
        didSet {
            if isViewLoaded {
                updateTitle()
            }
        }
    }
    
    private func updateTitle() {
        if let string = title {
            titleContainerView.isHidden = false
            stackView.updateConstraintsIfNeeded() // force remove height constraint
            
            if let label = titleContainerView.subviews.first?.subviews.first as? UILabel {
                label.text = string
            } else {
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.textAlignment = .center
                label.numberOfLines = 0
                label.textColor = .white
                label.font = .boldSystemFont(ofSize: 17)
                label.text = string
                let layoutMarginTop: CGFloat = stackView.arrangedSubviews.count == 0 ? 0 : 11
                WrapViewInContainerViewAndAddToStackView(stackView, containerView: titleContainerView, subview: label, layoutMargins: UIEdgeInsets(top: layoutMarginTop, left: kLayoutMarginsHorizontal, bottom: 11, right: kLayoutMarginsHorizontal), layout: .centerHorizontaly)
            }
        } else {
            titleContainerView.subviews.forEach {$0.removeFromSuperview()}
            titleContainerView.isHidden = true
        }
    }
    
    // MARK: - Configuring Message
    
    private let messageContainerView = UIView()
    
    var message: String? {
        didSet {
            if isViewLoaded {
                updateMessage()
            }
        }
    }

    private func updateMessage() {
        if let string = message {
            messageContainerView.isHidden = false
            stackView.updateConstraintsIfNeeded() // force remove height constraint
            
            if let label = messageContainerView.subviews.first?.subviews.first as? UILabel {
                label.text = string
            } else {
                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.textAlignment = .center
                label.numberOfLines = 0
                label.textColor = .white
                label.font = .systemFont(ofSize: 15, weight: .light)
                label.text = string
                let layoutMarginTop: CGFloat = stackView.arrangedSubviews.count == 0 ? 0 : 11
                WrapViewInContainerViewAndAddToStackView(stackView, containerView: messageContainerView, subview: label, layoutMargins: UIEdgeInsets(top: layoutMarginTop, left: kLayoutMarginsHorizontal, bottom: 11, right: kLayoutMarginsHorizontal), layout: .centerHorizontaly)
            }
        } else {
            messageContainerView.subviews.forEach {$0.removeFromSuperview()}
            messageContainerView.isHidden = true
        }
    }
    
    // MARK: - Configuring Content View Controller
    
    private let contentViewControllerContainerView = UIView()
    
    /// You are required to setup preferredContentSize.height for `viewController`
    var contentViewController: UIViewController? {
        didSet {
            if isViewLoaded {
                updateContentViewController()
            }
        }
    }
    
    private func updateContentViewController() {
        // remove old content view controller
        for viewController in children {
            viewController.willMove(toParent: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
        }
        contentViewControllerContainerView.subviews.forEach {$0.removeFromSuperview()}
        
        if let viewController = contentViewController {
            contentViewControllerContainerView.isHidden = false
            stackView.updateConstraintsIfNeeded() // force remove height constraint
            
            addChild(viewController)
            viewController.view.translatesAutoresizingMaskIntoConstraints = false
            viewController.view.heightAnchor.constraint(equalToConstant: viewController.preferredContentSize.height).isActive = true
            WrapViewInContainerViewAndAddToStackView(stackView, containerView: contentViewControllerContainerView, subview: viewController.view, layoutMargins: .zero, layout: .pinToEdges)
            viewController.didMove(toParent: self)
        } else {
            contentViewControllerContainerView.isHidden = true
        }
    }
    
    // MARK: - Configuring Actions
    
    private let actionsContainerView = UIView()
    private(set) var actions = [ActionSheetAction]()
    
    func addAction(_ action: ActionSheetAction) {
        actions.append(action)
    }
    
    // MARK: - Building Items
    
    private func insertArrangedSubviewsToStackView() {
        updateImageView()
        updateTitle()
        updateMessage()
        updateContentViewController()

        if actions.count > 0 {
            // separator
            do {
                let view = SeparatorView()
                view.translatesAutoresizingMaskIntoConstraints = false
                view.backgroundColor = UIColor(r: 56, g: 65, b: 88)
                let layoutMarginTop: CGFloat = stackView.arrangedSubviews.count == 0 ? 0 : 11
                WrapViewInContainerViewAndAddToStackView(stackView, containerView: separatorContainerView, subview: view, layoutMargins: UIEdgeInsets(top: layoutMarginTop, left: 0, bottom: 0, right: 0), layout: .pinToEdges)
            }

            // actions
            let buttonsView = UIStackView()
            buttonsView.translatesAutoresizingMaskIntoConstraints = false
            buttonsView.heightAnchor.constraint(equalToConstant: 52).isActive = true
            buttonsView.axis = .horizontal
            buttonsView.alignment = .fill
            buttonsView.distribution = .fillEqually
            buttonsView.spacing = 0
            for action in actions {
                let button = UIButton(type: .system)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.setTitle(action.title, for: .normal)
                switch action.style {
                case .default, .cancel:
                    button.setTitleColor(.white, for: .normal)
                case .destructive:
                    button.setTitleColor(UIColor(r: 235, g: 0, b: 0), for: .normal)
                case .custom(let textColor):
                    button.setTitleColor(textColor, for: .normal)
                }
                button.addTarget(self, action: #selector(actionButtonTapped(sender:)), for: .touchUpInside)
                if let preferredAction = preferredAction, action === preferredAction {
                    button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
                } else {
                    button.titleLabel?.font = .systemFont(ofSize: 17)
                }
                button.sizeToFit()
                buttonsView.addArrangedSubview(button)
            }
            WrapViewInContainerViewAndAddToStackView(stackView, containerView: buttonsContainerView, subview: buttonsView, layoutMargins: .zero, layout: .pinToEdges)
        }
    }
    
    // MARK: - Action Handling
    
    @objc
    private func actionButtonTapped(sender: UIButton) {
        guard let buttonIndex = sender.superview?.subviews.index(of: sender) else { return }
        let action = actions[buttonIndex]
        dismiss(animated: IsAnimationAllowed()) {
            action.handler?(action)
        }
    }
    
    // MARK: - Transitioning Delegate
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard presented is ActionSheetController else { return nil }
        return FadeAnimator(isPresenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard dismissed is ActionSheetController else { return nil }
        return FadeAnimator(isPresenting: false)
    }
    
    // MARK: - Observing Keyboard Notifications
    
    private var keyboardBottomInset: CGFloat = 0
    
    private func setKeyboardNotificationsObservationEnabled(_ enabled: Bool) {
        let notificationCenter = NotificationCenter.default
        if enabled {
            notificationCenter.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        } else {
            notificationCenter.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        }
    }
    
    @objc
    private func keyboardWillChangeFrame(notification: NSNotification) {
        guard isViewLoaded, let userInfo = notification.userInfo else { return }
        performAlongKeyboardAnimation(userInfo: userInfo, animations: { [weak self] in
            self?.updateScrollViewContentSizeAndInsetsIfNeeded()
            }, completion: nil)
    }
    
    private func performAlongKeyboardAnimation(userInfo: [AnyHashable: Any], animations: @escaping () -> Void, completion: ((Bool) -> Void)?) {
        let userInfo = KeyboardObserver.UserInfo(userInfo: userInfo)
        let frameBegin = userInfo.frameBegin
        let frameEnd = userInfo.frameEnd
        let duration = userInfo.duration
        let options = userInfo.curve.union(.allowUserInteraction)
        
        let frameBeginInView = view.convert(frameBegin, from: nil)
        let frameEndInView = view.convert(frameEnd, from: nil)
        
        // layout subviews before animation
        keyboardBottomInset = max(0, view.frame.maxY - frameBeginInView.minY)
        animations()
        view.layoutIfNeeded()
        scrollView.layoutIfNeeded()
        
        // animate
        keyboardBottomInset = max(0, view.frame.maxY - frameEndInView.minY)
        let animated = frameEnd.minY != frameBegin.minY
        if animated {
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations, completion: completion)
        } else {
            animations()
        }
    }
    
    // MARK: - Responding to Changes in Child View Controllers
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        guard let viewController = container as? UIViewController else { return }
        let height = viewController.view.constraintsAffectingLayout(for: .vertical).first {$0.firstItem as? UIView == viewController.view && $0.firstAttribute == .height && $0.relation == .equal}
        UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseOut, animations: {
            height?.constant = viewController.preferredContentSize.height
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
}
