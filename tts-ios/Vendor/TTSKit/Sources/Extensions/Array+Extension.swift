//
//  Array+Extension.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 21/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

extension Array {
    
    mutating func mapInPlace(_ transform: (Element) -> Element) {
        self = map(transform)
    }
    
}
