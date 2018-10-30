//
//  AuthUserNameViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 28/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

final class AuthUserNameViewController: ScrollViewController, ErrorPresenting, UITextFieldDelegate {

    @IBOutlet private var firstNameTextField: UITextField!
    @IBOutlet private var lastNameTextField: UITextField!
    @IBOutlet private var submitButton: SubmitButton!
    
    private let interactor: AuthUserNameInteractor
    private let completion: () -> Void
    
    init(interactor: AuthUserNameInteractor, completion: @escaping () -> Void) {
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
        
        validate()
        setLoading(false)
        firstNameTextField.becomeFirstResponder()
    }
    
    // MARK: - Responding to View Events
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        firstNameTextField.becomeFirstResponder()
    }
    
    // MARK: - Loading
    
    private func setLoading(_ loading: Bool) {
        firstNameTextField.isEnabled = !loading
        lastNameTextField.isEnabled = !loading
        submitButton.isUserInteractionEnabled = !loading
        loading ? submitButton.startAnimating() : submitButton.stopAnimating()
    }
    
    // MARK: - Text Field
    
    @IBAction
    private func textFieldEditingChanged(sender: UITextField) {
        if sender == firstNameTextField {
            interactor.setFirstName(sender.text)
        } else if sender == lastNameTextField {
            interactor.setLastName(sender.text)
        }
        validate()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameTextField {
            lastNameTextField.becomeFirstResponder()
        } else if textField == lastNameTextField {
            if submitButton.isEnabled {
                submit()
            }
        }
        return true
    }
    
    // MARK: - Validating
    
    private func validate() {
        submitButton.isEnabled = interactor.isFormValid()
    }
    
    // MARK: - Submitting
    
    @IBAction
    private func submitButtonTapped() {
        submit()
    }

    private func submit() {
        setLoading(true)
        interactor.addUserName { [weak self] in
            self?.setLoading(false)
            switch $0 {
            case .success:
                self?.completion()
            case .failure(let error):
                self?.showError(error)
            }
        }
    }
    
}
