//
//  UIDatePicker.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 19/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

extension UIDatePicker {
    
    public func addAction(forControlEvents controlEvents: UIControl.Event, _ action: @escaping (UIDatePicker) -> Void) {
        let box = BlockBox({ [weak self] in
            guard let `self` = self else { return }
            action(self)
        })
        addTarget(box, action: #selector(box.action), for: controlEvents)
        let key = Unmanaged.passUnretained(box).toOpaque()
        objc_setAssociatedObject(self, key, box, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
}
