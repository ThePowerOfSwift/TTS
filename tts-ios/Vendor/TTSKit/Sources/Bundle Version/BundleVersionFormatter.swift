//
//  BundleVersionFormatter.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public final class BundleVersionFormatter: Formatter {
    
    public func string(from bundleVersion: BundleVersion) -> String {
        if let appVersion = bundleVersion.appVersion {
            return appVersion + " (\(bundleVersion.buildNumber))"
        } else {
            return bundleVersion.buildNumber
        }
    }
    
    override public func string(for obj: Any?) -> String? {
        guard let bundleVersion = obj as? BundleVersion else { return nil }
        return string(from: bundleVersion)
    }
    
}
