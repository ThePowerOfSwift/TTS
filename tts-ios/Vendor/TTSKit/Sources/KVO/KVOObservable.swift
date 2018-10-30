//
//  KVOObservable.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 25/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import RxSwift

/// We use CwlKeyValueObserver to deal with an Exception on iOS 10 which is triggered when trying to remove observation while source is deallocating.
/// At this point, a `weak` var will be `nil` and an `unowned` will trigger a `_swift_abortRetainUnowned` failure.
/// So we're left with `Unmanaged`.
/// - see [KeyPath-based KVO: Unable to stop observing owned object on deinit](https://bugs.swift.org/browse/SR-5816)
public final class KVOObservable<T> : ObservableType {
    
    public typealias E = T?
    
    private let target: NSObject
    private let keyPath: String
    private let options: NSKeyValueObservingOptions
    
    ///
    /// - Parameters:
    ///     - target: won't be retained
    public init(target: NSObject, keyPath: String, options: NSKeyValueObservingOptions = [.new, .initial]) {
        self.target = target
        self.keyPath = keyPath
        self.options = options
    }
    
    public func subscribe<O>(_ observer: O) -> Disposable where O: ObserverType, KVOObservable.E == O.E {
        let observer = KeyValueObserver(source: target, keyPath: keyPath, options: options) { change, reason in
            guard reason == .valueChanged else { return }
            let new = change[.newKey]
            observer.onNext(new as? T)
        }
        
        return Disposables.create(with: observer.cancel)
    }
    
}
