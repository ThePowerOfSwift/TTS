//
//  KeyValueStorage.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import RxSwift

public protocol KeyValueStorage {
    
    func value(forKey key: String) -> Any?
    
    func setValue(_ value: Any?, forKey key: String)
    
    func observe<T>(_ type: T.Type, _ keyPath: String, options: NSKeyValueObservingOptions) -> Observable<T?>
    
}

extension UserDefaults: KeyValueStorage {
    
    public func observe<T>(_ type: T.Type, _ keyPath: String, options: NSKeyValueObservingOptions) -> Observable<T?> {
        return KVOObservable(target: self, keyPath: keyPath, options: options).asObservable()
    }
    
}
