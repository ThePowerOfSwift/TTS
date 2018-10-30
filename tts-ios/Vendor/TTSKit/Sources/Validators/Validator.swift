//
//  Validator.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public protocol Validator {
    
    associatedtype Value
    
    func validate(_ value: Value) throws
    
}
