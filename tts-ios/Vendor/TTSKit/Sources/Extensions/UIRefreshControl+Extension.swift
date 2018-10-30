//
//  UIRefreshControl+Extension.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 07/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import UIKit
import ObjectiveC

extension UIRefreshControl {
    
    public convenience init(_ action: @escaping () -> Void) {
        self.init()
        addAction(forControlEvents: .valueChanged, action)
    }
    
    public func addAction(forControlEvents controlEvents: UIControl.Event, _ action: @escaping () -> Void) {
        let box = BlockBox(action)
        addTarget(box, action: #selector(box.action), for: controlEvents)
        let key = Unmanaged.passUnretained(box).toOpaque()
        objc_setAssociatedObject(self, key, box, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

}
