//
//  BundleVersionTracker.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public final class BundleVersionTracker {
    
    public enum LaunchType: Int {
        
        case undefined
        
        case firstRun
        
        case update
        
    }
    
    private var bundleVersion: BundleVersionUserValue
    
    private var bundle: BundleVersionAccessible
    
    public var type: LaunchType = .undefined
    
    public init(storage: KeyValueStorage = UserDefaults.standard, bundle: BundleVersionAccessible = Bundle.main) {
        self.bundleVersion = BundleVersionUserValue(storage: storage)
        self.bundle = bundle
        detectBundleVersion()
    }
    
    private func detectBundleVersion() {
        guard let currentBundleVersion = bundle.bundleVersion else {
            return
        }
        
        if let storedBundleVersion = bundleVersion.get() {
            if storedBundleVersion != currentBundleVersion {
                type = .update
            }
        } else {
            type = .firstRun
        }
    }
    
    public func saveCurrentBundleVersion() {
        guard let currentBundleVersion = bundle.bundleVersion else {
            return
        }
        
        bundleVersion.set(currentBundleVersion)
    }
    
    public func resetCurrentBundleVersion() {
        bundleVersion.set(nil)
        detectBundleVersion()
    }
    
}
