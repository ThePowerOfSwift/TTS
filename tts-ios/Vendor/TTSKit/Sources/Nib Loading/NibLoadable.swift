//
//  NibLoadable.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit

public protocol NibLoadable: class {
    
    static var nib: UINib { get }
    
}

extension NibLoadable {
    
    static public var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    public static func loadFromNib(withOwner owner: Any? = nil, options: [UINib.OptionsKey: Any]? = nil) -> Self? {
        return nib.instantiate(withOwner: owner, options: options).first as? Self
    }
    
}
