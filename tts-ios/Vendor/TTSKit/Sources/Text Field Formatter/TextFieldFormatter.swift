//
//  TextFieldFormatter.swift
//  tts
//
//  Created by Dmitry Nesterenko on 22/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit

public final class TextFieldFormatter {
    
    public weak var textField: UITextField?
    
    public let mask: TextMask
    
    public init(textField: UITextField, mask: TextMask) {
        self.mask = mask
        self.textField = textField
        
        textField.addTarget(self, action: #selector(textFieldEditingChanged(sender:)), for: .editingChanged)
        textField.addTarget(self, action: #selector(textFieldDidBeginEditing(sender:)), for: .editingDidBegin)
        applyMask()
    }
    
    // MARK: - Text Field State
    
    public func applyMask() {
        guard let textField = textField else { return }

        setText(textField.text)
    }
    
    public func setText(_ text: String?) {
        guard let textField = textField else { return }
        
        // In order to make the cursor end up positioned correctly, we need to
        // explicitly reposition it after we inject spaces into the text.
        // targetCursorPosition keeps track of where the cursor needs to end up as
        // we modify the string, and at the end we set the cursor position to it.
        var targetCursorPosition: Int?
        if let selectedTextRange = textField.selectedTextRange {
            targetCursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedTextRange.start)
        }
        
        textField.text = mask.maskedString(from: text ?? "", cursorPosition: &targetCursorPosition)
        
        if textField.isFirstResponder, let targetCursorPosition = targetCursorPosition {
            if let targetPosition = textField.position(from: textField.beginningOfDocument, offset: targetCursorPosition) {
                textField.selectedTextRange = textField.textRange(from: targetPosition, to: targetPosition)
            }
        }
    }
    
    // MARK: - Editing Changed
    
    @objc
    private func textFieldDidBeginEditing(sender: UITextField) {
        // UITextField's selected range will not be in effect after `.editingDidBegin` notification has been handled.
        // So we dispatch it as soon as possible after the `.editingDidBegin` completes.
        DispatchQueue.main.async {
            self.applyMask()
        }
    }

    @objc
    private func textFieldEditingChanged(sender: UITextField) {
        applyMask()
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return mask.shouldChange(text: textField.text, with: string, in: range)
    }
    
}
