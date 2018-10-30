//
//  UIBarButtonItem+Extension.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 22/05/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import UIKit
import ObjectiveC

extension UIBarButtonItem {
    
    public convenience init(image: UIImage?, style: UIBarButtonItem.Style, block: (() -> Void)?) {
        guard let block = block else {
            self.init(image: image, style: style, target: nil, action: nil)
            return
        }
        
        let box = BlockBox(block)
        self.init(image: image, style: style, target: box, action: #selector(box.action))
        let key = Unmanaged.passUnretained(box).toOpaque()
        objc_setAssociatedObject(self, key, box, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    public convenience init(title: String?, style: UIBarButtonItem.Style, block: (() -> Void)?) {
        guard let block = block else {
            self.init(title: title, style: style, target: nil, action: nil)
            return
        }
        
        let box = BlockBox(block)
        self.init(title: title, style: style, target: box, action: #selector(box.action))
        let key = Unmanaged.passUnretained(box).toOpaque()
        objc_setAssociatedObject(self, key, box, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    public convenience init(barButtonSystemItem: UIBarButtonItem.SystemItem, block: (() -> Void)?) {
        guard let block = block else {
            self.init(barButtonSystemItem: barButtonSystemItem, target: nil, action: nil)
            return
        }
        
        let box = BlockBox(block)
        self.init(barButtonSystemItem: barButtonSystemItem, target: box, action: #selector(box.action))
        let key = Unmanaged.passUnretained(box).toOpaque()
        objc_setAssociatedObject(self, key, box, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    public convenience init(image: UIImage?, landscapeImagePhone: UIImage?, style: UIBarButtonItem.Style, block: (() -> Void)?) {
        guard let block = block else {
            self.init(image: image, landscapeImagePhone: landscapeImagePhone, style: style, target: nil, action: nil)
            return
        }
        
        let box = BlockBox(block)
        self.init(image: image, landscapeImagePhone: landscapeImagePhone, style: style, target: box, action: #selector(box.action))
        let key = Unmanaged.passUnretained(box).toOpaque()
        objc_setAssociatedObject(self, key, box, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
}
