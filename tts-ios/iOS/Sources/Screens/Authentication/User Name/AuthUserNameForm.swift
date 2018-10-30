//
//  AuthUserNameForm.swift
//  tts
//
//  Created by Dmitry Nesterenko on 28/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit

@objcMembers
final class AuthUserNameForm: Form {
    
    enum Error: Swift.Error {
        case firstNameInvalid
        case lastNameInvalid
    }
    
    var firstName: String?
    var lastName: String?
    
    func validateFirstName(_ ioValue: AutoreleasingUnsafeMutablePointer<AnyObject?>) throws {
        guard let text = ioValue.pointee as? String, text.count > 0 else {
            throw Error.firstNameInvalid
        }
    }

    func validateLastName(_ ioValue: AutoreleasingUnsafeMutablePointer<AnyObject?>) throws {
        guard let text = ioValue.pointee as? String, text.count > 0 else {
            throw Error.lastNameInvalid
        }
    }
    
}
