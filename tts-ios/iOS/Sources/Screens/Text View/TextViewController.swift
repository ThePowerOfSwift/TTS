//
//  TextViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

protocol TextViewControllerDelegate: class {
    func textViewController(_ viewController: TextViewController, didCompleteWithText text: String?)
}

final class TextViewController: UIViewController {
    
    @IBOutlet private var topSpace: NSLayoutConstraint!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var textView: UITextView!
    @IBOutlet private var submitButton: SubmitButton!
    
    weak var delegate: TextViewControllerDelegate?
    private var behavior: KeepSubmitButtonAlwaysOnTopOfKeyboardBehavior!
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTopSpace()
        
        behavior = KeepSubmitButtonAlwaysOnTopOfKeyboardBehavior(submitButton: submitButton)
        textView.becomeFirstResponder()
    }
    
    // MARK: - Extending the View's Safe Area
    
    @available(iOS 11.0, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        updateTopSpace()
        behavior.layoutAtBottomGuide()
    }

    // MARK: - Configuring the View’s Layout Behavior
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateTopSpace()
    }
    
    private func updateTopSpace() {
        if #available(iOS 11.0, *) {
            topSpace.constant = view.safeAreaInsets.top
        } else {
            topSpace.constant = max(navigationController?.navigationBar.frame.maxY ?? 0, topLayoutGuide.length)
        }
    }
    
    // MARK: - Actions
    
    @IBAction
    private func submitButtonTapped() {
        delegate?.textViewController(self, didCompleteWithText: textView.text)
    }
    
}
