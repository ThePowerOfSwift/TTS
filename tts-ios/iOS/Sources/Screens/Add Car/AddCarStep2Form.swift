//
//  AddCarStep2Form.swift
//  tts
//
//  Created by Dmitry Nesterenko on 12/03/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit

@objcMembers
class AddCarStep2Form: Form {
    
    enum Error: LocalizedError {
        case numberPlateInvalid(underlying: Swift.Error?)
        case vinInvalid(underlying: Swift.Error?)
        case mileageInvalid(underlying: Swift.Error?)
        
        var errorDescription: String? {
            switch self {
            case .numberPlateInvalid:
                return "Неверный гос номер"
            case .vinInvalid:
                return "Неверный VIN"
            case .mileageInvalid:
                return "Неверный пробег"
            }
        }
    }
    
    var numberPlate: String?
    
    var vin: String?
    
    var mileage: String?
    
    func validateNumberPlate(_ ioValue: AutoreleasingUnsafeMutablePointer<AnyObject?>) throws {
        guard let text = ioValue.pointee as? String, text.count > 0 else {
            throw Error.numberPlateInvalid(underlying: nil)
        }
        
        do {
            try NumberPlateValidator().validate(text)
        } catch {
            throw Error.numberPlateInvalid(underlying: error)
        }
    }

    func validateVin(_ ioValue: AutoreleasingUnsafeMutablePointer<AnyObject?>) throws {
        guard let text = ioValue.pointee as? String, text.count > 0 else {
            throw Error.vinInvalid(underlying: nil)
        }
        
        do {
            try VinValidator().validate(text)
        } catch {
            throw Error.vinInvalid(underlying: error)
        }
    }
    
    func validateMileage(_ ioValue: AutoreleasingUnsafeMutablePointer<AnyObject?>) throws {
        guard let text = ioValue.pointee as? String, text.count > 0 else {
            throw Error.mileageInvalid(underlying: nil)
        }
        
        do {
            try MileageValidator().validate(text)
        } catch {
            throw Error.mileageInvalid(underlying: error)
        }
    }
    
}
