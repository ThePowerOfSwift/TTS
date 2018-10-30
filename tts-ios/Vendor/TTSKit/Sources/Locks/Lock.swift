//
//  Lock.swift
//  tts
//
//  Created by Dmitry Nesterenko on 21/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public protocol Lockable {
    
    func lock()
    
    func unlock()
    
}

public extension Lockable {
    
    func withLocked(handler: () throws -> Void) rethrows {
        lock()
        defer { unlock() }
        return try handler()
    }
    
}

@available(iOS 10, *)
public final class UnfairLock: Lockable {
    
    var unfairLock: os_unfair_lock
    
    init() {
        unfairLock = os_unfair_lock()
    }
    
    public func lock() {
        os_unfair_lock_lock(&unfairLock)
    }
    
    public func unlock() {
        os_unfair_lock_unlock(&unfairLock)
    }
    
}

public final class MutexLock: Lockable {
    
    var mutex: pthread_mutex_t
    
    deinit {
        pthread_mutex_destroy(&mutex)
    }
    
    init() {
        mutex = pthread_mutex_t()
        pthread_mutex_init(&mutex, nil)
    }
    
    public func lock() {
        pthread_mutex_lock(&mutex)
    }
    
    public func unlock() {
        pthread_mutex_unlock(&mutex)
    }
    
}

public final class RecursiveLock: Lockable {
    
    private var recursiveLock: NSRecursiveLock
    
    init() {
        recursiveLock = NSRecursiveLock()
    }
    
    public func lock() {
        recursiveLock.lock()
    }
    
    public func unlock() {
        recursiveLock.unlock()
    }
    
}

public final class Lock: Lockable {
    
    private var lockable: Lockable
    
    public init() {
        if #available(iOS 10, *) {
            lockable = UnfairLock()
        } else {
            lockable = MutexLock()
        }
    }
    
    public func lock() {
        lockable.lock()
    }
    
    public func unlock() {
        lockable.unlock()
    }
    
}
