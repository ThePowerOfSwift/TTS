//
//  URLBehavior.swift
//  tts
//
//  Created by Dmitry Nesterenko on 08/09/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public protocol URLBehavior {
    
    func willSend(request: inout Foundation.URLRequest)

    func didSend(request: inout Foundation.URLRequest)
    
    // called right after executor completed and before request validation and mapping occurs
    func willComplete(response: inout HTTPURLResponse?, data: inout Data?, error: inout Error?)
    
    // called right after request validation and mapping occured
    func didComplete(response: inout HTTPURLResponse?, data: inout Data?, error: inout Error?)
    
}
