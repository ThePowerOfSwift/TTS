//
//  UIGeometry+Extension.swift
//  tts
//
//  Created by Dmitry Nesterenko on 26/09/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public func + (lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
    return UIEdgeInsets(top: lhs.top + rhs.top, left: lhs.left + rhs.left, bottom: lhs.bottom + rhs.bottom, right: lhs.right + rhs.right)
}
