//
//  AuthPhoneForm.swift
//  tts
//
//  Created by Dmitry Nesterenko on 26/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import TTSKit

@objcMembers
final class AuthPhoneForm: Form {
    
    enum Error: Swift.Error {
        case invalidPhoneNumber
    }
    
    var phoneNumber: String?
    
    let phoneNumberPrefix: String?
    
    init(phoneNumberPrefix: String?) {
        self.phoneNumberPrefix = phoneNumberPrefix
    }
    
    func validatePhoneNumber(_ ioValue: AutoreleasingUnsafeMutablePointer<AnyObject?>) throws {
        guard let text = ioValue.pointee as? String, text.count > 0 else {
            throw Error.invalidPhoneNumber
        }
        
        let validator = PhoneNumberValidator(prefix: phoneNumberPrefix)

        let deprecatedCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "+")).inverted
        let string = text.replacing(charactersIn: deprecatedCharacters, with: "")
        try validator.validate(string)
    }
    
}
