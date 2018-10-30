//
//  AddCarStep2ViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 01/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit
import IGListKit
import SwiftMessages

protocol AddCarStep2ViewControllerDelegate: class {
    func addCarStep2ViewController(_ viewController: AddCarStep2ViewController, didCompleteWithBrand brand: CarBrand, modelId: Int, year: Int, complectationId: Int?, gosnomer: String, vin: String, mileage: Int)
}

final class AddCarStep2ViewController: ScrollViewController, UITextFieldDelegate {
    
    weak var delegate: AddCarStep2ViewControllerDelegate?
    @IBOutlet private var progressView: UIProgressView!
    @IBOutlet private var numberPlateContainerView: UIView!
    @IBOutlet private var numberPlateLabel: UILabel!
    @IBOutlet private var numberPlateTextField: UITextField!
    @IBOutlet private var numberPlateErrorLineView: UIView!
    @IBOutlet private var vinContainerView: UIView!
    @IBOutlet private var vinLabel: UILabel!
    @IBOutlet private var vinTextField: UITextField!
    @IBOutlet private var vinErrorLineView: UIView!
    @IBOutlet private var mileageContainerView: UIView!
    @IBOutlet private var mileageLabel: UILabel!
    @IBOutlet private var mileageTextField: UITextField!
    @IBOutlet private var mileageErrorLineView: UIView!
    @IBOutlet private var submitButton: SubmitButton!
    private let brand: CarBrand
    private let modelId: Int
    private let year: Int
    private let complectationId: Int?
    private let form = AddCarStep2Form()
    private var numberPlateTextFieldFormatter: TextFieldFormatter!
    private var vinTextFieldFormatter: TextFieldFormatter!
    private var mileageTextFieldFormatter: TextFieldFormatter!
    
    init(brand: CarBrand, modelId: Int, year: Int, complectationId: Int?) {
        self.brand = brand
        self.modelId = modelId
        self.year = year
        self.complectationId = complectationId
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(progressView)
        
        numberPlateTextField.text = nil
        vinTextField.text = nil
        mileageTextField.text = nil
        
        numberPlateTextFieldFormatter = TextFieldFormatter(textField: numberPlateTextField, mask: UppercaseMask())
        vinTextFieldFormatter = TextFieldFormatter(textField: vinTextField, mask: VinMask())
        mileageTextFieldFormatter = TextFieldFormatter(textField: mileageTextField, mask: MileageMask())
        
        setNumberPlateValid(true)
        setVinValid(true)
        setMileageValid(true)
        
        numberPlateTextField.becomeFirstResponder()
    }
    
    // MARK: - Configuring the View’s Layout Behavior
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        progressView.frame = CGRect(x: 0, y: topLayoutGuide.length, width: view.bounds.width, height: progressView.bounds.height)
    }
    
    // MARK: - Text Field
    
    @IBAction
    private func textFieldEditingChanged(sender: UITextField) {
        switch sender {
        case numberPlateTextField:
            setNumberPlateValid(true)
            form.numberPlate = sender.text
        case vinTextField:
            setVinValid(true)
            form.vin = sender.text
        case mileageTextField:
            setMileageValid(true)
            form.mileage = sender.text
        default:
            fatalError()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case numberPlateTextField:
            if numberPlateTextFieldFormatter.textField(textField, shouldChangeCharactersIn: range, replacementString: string) {
                return true
            } else {
                numberPlateContainerView.wobble()
                return false
            }
        case vinTextField:
            if vinTextFieldFormatter.textField(textField, shouldChangeCharactersIn: range, replacementString: string) {
                return true
            } else {
                vinContainerView.wobble()
                return false
            }
        case mileageTextField:
            if mileageTextFieldFormatter.textField(textField, shouldChangeCharactersIn: range, replacementString: string) {
                return true
            } else {
                mileageContainerView.wobble()
                return false
            }
        default:
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case numberPlateTextField:
            vinTextField.becomeFirstResponder()
        case vinTextField:
            mileageTextField.becomeFirstResponder()
        case mileageTextField:
            if form.errors.count == 0 {
                submit()
            }
        default:
            fatalError()
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case numberPlateTextField:
            let isValid = form.numberPlate == nil || form.isValidValue(forKey: "numberPlate")
            setNumberPlateValid(isValid)
        case vinTextField:
            let isValid = form.vin == nil || form.isValidValue(forKey: "vin")
            setVinValid(isValid)
        case mileageTextField:
            let isValid = form.mileage == nil || form.isValidValue(forKey: "mileage")
            setMileageValid(isValid)
        default:
            fatalError()
        }
    }
    
    override var inputAccessoryView: UIView? {
        return submitButton
    }
    
    // MARK: - Submitting
    
    @IBAction
    private func submitButtonTapped() {
        if form.error(forKey: "numberPlate") != nil {
            setNumberPlateValid(false)
        }
        if form.error(forKey: "vin") != nil {
            setVinValid(false)
        }
        if form.error(forKey: "mileage") != nil {
            setMileageValid(false)
        }
        
        if let error = form.errors.first {
            var config = SwiftMessages.Config()
            config.presentationContext = .window(windowLevel: UIWindow.Level.normal.rawValue)
            config.preferredStatusBarStyle = .lightContent
            let view = MessageView(text: error.localizedDescription, style: .black)
            view.statusBarOffset = UIApplication.shared.statusBarFrame.height
            view.safeAreaTopOffset = UIApplication.shared.statusBarFrame.height + 44
            SwiftMessages.show(config: config, view: view)
        } else {
            submit()
        }
    }
    
    private func submit() {
        guard let gosnomer = form.numberPlate, let vin = form.vin, let mileageString = form.mileage, let mileage = NumberFormatter().number(from: mileageString)?.intValue else { return }
        delegate?.addCarStep2ViewController(self, didCompleteWithBrand: brand, modelId: modelId, year: year, complectationId: complectationId, gosnomer: gosnomer, vin: vin, mileage: mileage)
    }
    
    // MARK: - Validating
    
    private func setNumberPlateValid(_ valid: Bool) {
        numberPlateErrorLineView.isHidden = valid
        setTitleLabel(numberPlateLabel, valid: valid)
    }
    
    private func setVinValid(_ valid: Bool) {
        vinErrorLineView.isHidden = valid
        setTitleLabel(vinLabel, valid: valid)
    }
    
    private func setMileageValid(_ valid: Bool) {
        mileageErrorLineView.isHidden = valid
        setTitleLabel(mileageLabel, valid: valid)
    }
    
    private func setTitleLabel(_ label: UILabel, valid: Bool) {
        label.textColor = valid ? UIColor(r: 112, g: 124, b: 137) : UIColor(r: 241, g: 52, b: 52)
    }
    
}
