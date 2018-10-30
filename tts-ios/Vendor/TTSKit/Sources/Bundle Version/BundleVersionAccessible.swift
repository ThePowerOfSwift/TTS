//
//  BundleVersionAccessible.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public protocol BundleVersionAccessible {
    
    var bundleVersion: BundleVersion? { get }
    
}

extension Bundle: BundleVersionAccessible {
    
    public var bundleVersion: BundleVersion? {
        guard let bundleVersion = object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String else { return nil }
        return BundleVersion(appVersion: object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String, buildNumber: bundleVersion)
    }
    
}
