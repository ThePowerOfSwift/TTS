//
//  BlockBox.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 07/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

final class BlockBox: NSObject {
    
    private var block: () -> Void
    
    init(_ block: @escaping () -> Void) {
        self.block = block
    }
    
    @objc
    func action() {
        block()
    }
    
}
