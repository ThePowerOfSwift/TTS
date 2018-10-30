//
//  Bundle+Extension.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

extension Bundle {
    
    public func object(forInfoDictionaryKeyPath keyPath: String) -> String? {
        return (infoDictionary as NSDictionary?)?.value(forKeyPath: keyPath) as? String
    }
    
}
