//
//  AuthPhoneViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 25/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

final class AuthPhoneViewController: ScrollViewController, ErrorPresenting, UITextFieldDelegate {
    
    @IBOutlet private var textField: UITextField!
    @IBOutlet private var supportButton: UIButton!
    @IBOutlet private var submitButton: SubmitButton!
    
    private let interactor: AuthPhoneInteractor
    private var textFieldFormatter: TextFieldFormatter!
    private var completion: (PhoneNumber, GetTempTokenResponse) -> Void
    
    init(interactor: AuthPhoneInteractor, completion: @escaping (PhoneNumber, GetTempTokenResponse) -> Void) {
        self.interactor = interactor
        self.completion = completion
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delaysContentTouches = false
        
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "title_logo"))
        textField.attributedPlaceholder = textField.placeholder?.with(StringAttributes {
            $0.font = textField.font!
            $0.foregroundColor = UIColor(r: 56, g: 65, b: 88)
        })
        
        textFieldFormatter = TextFieldFormatter(textField: textField, mask: PhoneMask(prefix: interactor.phoneNumberPrefix))
        setLoading(false)
    }
    
    // MARK: - Responding to View Events
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textField.becomeFirstResponder()
    }
    
    // MARK: - Managing the Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Text Field
    
    @IBAction
    private func textFieldEditingChanged(sender: UITextField) {
        interactor.setPhoneNumber(sender.text)
        validate()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textFieldFormatter.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if submitButton.isEnabled {
            submit()
        }
        return submitButton.isEnabled
    }
    
    // MARK: - Submitting
    
    func setSubmitButtonEnabled(_ enabled: Bool) {
        submitButton.isEnabled = enabled
    }
    
    @IBAction
    private func submitButtonTapped() {
        submit()
    }
    
    func submit() {
        setLoading(true)
        interactor.getTempToken { [weak self] in
            self?.setLoading(false)
            switch $0 {
            case .success(let result):
                self?.completion(result.0, result.1)
            case .failure(let error):
                self?.showError(error, animated: IsAnimationAllowed(), close: {
                    self?.textField.becomeFirstResponder()
                })
            }
        }
    }
    
    // MARK: - Validating
    
    private func validate() {
        setSubmitButtonEnabled(interactor.isFormValid())
    }
    
    // MARK: - Loading State
    
    func setLoading(_ loading: Bool) {
        textField.isEnabled = !loading
        submitButton.isUserInteractionEnabled = !loading
        loading ? submitButton.startAnimating() : submitButton.stopAnimating()
        validate()
    }
    
    // MARK: - Hot Line Calling
    
    @IBAction
    private func hotLineButtonTapped() {
        presentHotLineCallPrompt()
    }
    
    func setHotLinePhoneNumber(_ phoneNumber: String) {
        let title = "Горячая линия"
            .with(StringAttributes {
                $0.font = UIFont.systemFont(ofSize: 15, weight: .light)
                $0.foregroundColor = UIColor(r: 128, g: 140, b: 153)
                $0.lineSpacing = 6
            })
            .appending("\n")
            .appending(phoneNumber.with(StringAttributes {
                $0.font = UIFont.systemFont(ofSize: 17, weight: .light)
                $0.foregroundColor = .white
            }))
        supportButton.titleLabel?.numberOfLines = 2
        supportButton.setAttributedTitle(title, for: .normal)
    }
    
    func presentHotLineCallPrompt() {
        let phone = PhoneNumberFormatter().string(from: CallAction.hotLinePhoneNumber)
        let viewController = UIAlertController(title: "Позвонить \(phone)", message: nil, preferredStyle: .alert)
        viewController.addAction(UIAlertAction(title: "Позвонить", style: .default, handler: { [weak self] _ in
            self?.interactor.callHotLine()
        }))
        viewController.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        viewController.preferredAction = viewController.actions.first
        present(viewController, animated: IsAnimationAllowed(), completion: nil)
    }
    
}
