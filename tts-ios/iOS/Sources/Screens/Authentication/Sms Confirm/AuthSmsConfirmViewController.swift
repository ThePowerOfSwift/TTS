//
//  AuthSmsConfirmViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 27/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

final class AuthSmsConfirmViewController: ScrollViewController, ErrorPresenting, UITextFieldDelegate {

    @IBOutlet private var phoneLabel: UILabel!
    @IBOutlet private var smsCodeSpinner: UIActivityIndicatorView!
    @IBOutlet private var textField: UITextField!
    @IBOutlet private var timerTitleLabel: UILabel!
    @IBOutlet private var timerCountdownLabel: UILabel!
    @IBOutlet private var timerIconImageView: UIImageView!
    @IBOutlet private var timerButton: UIButton!
    @IBOutlet private var timerSpinner: UIActivityIndicatorView!
    
    private let interactor: AuthSmsConfirmInteractor
    private let completion: (GetAccessTokenResponse) -> Void
    
    init(interactor: AuthSmsConfirmInteractor, completion: @escaping (GetAccessTokenResponse) -> Void) {
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

        phoneLabel.text = PhoneMask(prefix: "+7").maskedString(from: interactor.phone.rawValue)

        textField.attributedPlaceholder = textField.placeholder?.with(StringAttributes {
            $0.font = textField.font!
            $0.foregroundColor = UIColor(r: 56, g: 65, b: 88)
        })
        
        startSmsCountdownTimeout()
        setLoading(false)
        textField.becomeFirstResponder()
    }
    
    // MARK: - Responding to View Events
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textField.becomeFirstResponder()
    }
    
    // MARK: - Text Field
    
    @IBAction
    private func textFieldEditingChanged(sender: UITextField) {
        let numberOfCharacters = sender.text?.count ?? 0
        if numberOfCharacters >= 8 {
            submit()
        }
    }
    
    // MARK: - Loading
    
    func setLoading(_ loading: Bool) {
        textField.isEnabled = !loading
        loading ? smsCodeSpinner.startAnimating() : smsCodeSpinner.stopAnimating()
    }
    
    // MARK: - Submitting
    
    func submit() {
        guard let text = textField.text else { return }
        setLoading(true)
        interactor.getAccessToken(smsCode: text) { [weak self] in
            self?.setLoading(false)
            self?.textField.becomeFirstResponder()
            
            switch $0 {
            case .success(let response):
                self?.completion(response)
            case .failure(let error):
                self?.textField.text = nil
                self?.showError(error, animated: IsAnimationAllowed(), close: {
                    self?.textField.becomeFirstResponder()
                })
            }
        }
    }
    
    // MARK: - Sms Timeout Handling
    
    private func setTimerCounter(_ timeout: TimeInterval) {
        timerCountdownLabel.text = "\(Int(timeout))"
    }
    
    private func startSmsCountdownTimeout() {
        setSmsResendButtonHidden(true)
        let timeInterval: TimeInterval = 120
        interactor.scheduleTimeoutCountdown(timeInterval: timeInterval, tick: { [weak self] in
            self?.setTimerCounter(timeInterval - $0)
        }, completion: { [weak self] in
            self?.setSmsResendButtonHidden(false)
        })
    }
    
    private func setSmsResendButtonHidden(_ hidden: Bool) {
        timerTitleLabel.isHidden = !hidden
        timerCountdownLabel.isHidden = !hidden
        timerIconImageView.isHidden = !hidden
        timerButton.isHidden = hidden
    }
    
    @IBAction
    private func resendButtonTapped() {
        timerButton.isEnabled = false
        timerSpinner.startAnimating()
        
        interactor.getTempToken { [weak self] in
            self?.timerButton.isEnabled = true
            self?.timerSpinner.stopAnimating()
            
            switch $0 {
            case .success:
                self?.startSmsCountdownTimeout()
            case .failure(let error):
                self?.showError(error)
            }
        }
    }
    
}
