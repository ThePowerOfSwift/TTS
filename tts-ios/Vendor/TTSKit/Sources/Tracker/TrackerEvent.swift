//
//  TrackerEvent.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public protocol TrackerEvent {
    
    var message: String { get }
    
    var parameters: [AnyHashable: Any]? { get }
    
}
