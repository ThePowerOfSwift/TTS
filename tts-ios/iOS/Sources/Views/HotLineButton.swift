//
//  HotLineButton.swift
//  tts
//
//  Created by Dmitry Nesterenko on 26/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit

final class HotLineButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        do {
            var frame = imageView!.frame
            frame.origin.x = bounds.maxX - imageView!.bounds.size.width - 16
            imageView?.frame = frame
        }
        
        do {
            var frame = titleLabel!.frame
            frame.origin.x = 16
            titleLabel?.frame = frame
        }
    }
    
}
