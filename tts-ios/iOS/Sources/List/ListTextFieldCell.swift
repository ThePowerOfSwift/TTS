//
//  ListTextFieldCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 29/05/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

final class ListTextFieldCell: TableViewCollectionViewCell, UITextFieldDelegate {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet var textField: UITextField!
    @IBOutlet private var titleLabelLeadingSpace: NSLayoutConstraint!
    @IBOutlet private var textFieldTopSpace: NSLayoutConstraint!
    
    var textFieldFormatter: TextFieldFormatter?
    
    var attributedTitle: NSAttributedString? {
        get {
            return titleLabel.attributedText
        }
        set {
            titleLabel.attributedText = newValue
            updateTextFieldTopSpace()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = nil
        selectionStyle = .none
        separatorColor = UIColor(r: 57, g: 65, b: 88)
        updateTextFieldTopSpace()
    }
    
    // MARK: - Text Field
    
    var shouldBeginEditing: (() -> Bool)?
    var shouldReturn: (() -> Bool)?
    
    private func updateTextFieldTopSpace() {
        let numberOfCharacters = titleLabel.attributedText?.length ?? 0
        if numberOfCharacters == 0 {
            textFieldTopSpace.constant = 0
        } else {
            textFieldTopSpace.constant = 16
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return shouldBeginEditing?() ?? true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return shouldReturn?() ?? true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldFormatter = textFieldFormatter else { return true }
        if textFieldFormatter.textField(textField, shouldChangeCharactersIn: range, replacementString: string) {
            return true
        } else {
            wobble()
            return false
        }
    }
    
}
