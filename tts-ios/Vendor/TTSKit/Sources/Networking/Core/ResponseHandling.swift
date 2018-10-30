//
//  ResponseHandling.swift
//  tts
//
//  Created by Dmitry Nesterenko on 17/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public protocol ResponseHandling {
    
    associatedtype Value
    
    func handle(response: HTTPURLResponse?, data: Data?, error: Error?) throws -> Value
    
}
