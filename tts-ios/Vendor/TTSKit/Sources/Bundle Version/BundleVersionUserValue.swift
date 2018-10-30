//
//  BundleVersionUserValue.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 25/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public final class BundleVersionUserValue: UserValue {
    
    let storage: KeyValueStorage
    
    public required init(storage: KeyValueStorage) {
        self.storage = storage
    }
    
    public func set(_ value: BundleVersion?) {
        if let value = value {
            let data = try! JSONEncoder().encode(value) // swiftlint:disable:this force_try
            storage.setValue(data, forKey: type(of: self).key)
        } else {
            storage.setValue(nil, forKey: type(of: self).key)
        }
    }
    
    public func get() -> BundleVersion? {
        guard let data = storage.value(forKey: type(of: self).key) as? Data else { return nil }
        return try? JSONDecoder().decode(BundleVersion.self, from: data)
    }
    
}
