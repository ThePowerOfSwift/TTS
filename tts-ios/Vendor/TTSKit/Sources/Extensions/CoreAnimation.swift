//
//  CoreAnimation.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 21/05/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public func IsAnimationAllowed() -> Bool {
    var isUnderHighload: Bool = false
    if #available(iOS 11.0, *) {
        isUnderHighload = ProcessInfo.processInfo.thermalState == .serious || ProcessInfo.processInfo.thermalState == .critical
    }
    
    let isLowPowerModeEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
    let isReduceMotionEnabled = UIAccessibility.isReduceMotionEnabled
    
    return !isLowPowerModeEnabled && !isReduceMotionEnabled && !isUnderHighload
}
