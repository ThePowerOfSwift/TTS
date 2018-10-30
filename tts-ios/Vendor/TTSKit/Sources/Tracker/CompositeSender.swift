//
//  CompositeSender.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public final class CompositeSender: MutableCollection, TrackerSender {
    
    var senders = [TrackerSender]()
    
    public init(senders: [TrackerSender]) {
        self.senders = senders
    }
    
    public func activate() {
        forEach { $0.activate() }
    }
    
    public func accept(_ event: TrackerEvent) -> Bool {
        return true
    }
    
    public func send(_ event: TrackerEvent) {
        forEach {
            if $0.accept(event) {
                $0.send(event)
            }
        }
    }
    
    public func applicationDidBecomeActive() {
        senders.forEach { $0.applicationDidBecomeActive() }
    }
    
    public func continueUserActivity(_ userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) {
        senders.forEach { $0.continueUserActivity(userActivity, restorationHandler: restorationHandler) }
    }
    
    public func openUrl(_ url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) {
        senders.forEach { $0.openUrl(url, options: options) }
    }
    
    // MARK: Mutable Collection
    
    public func index(after i: Int) -> Int {
        return senders.index(after: i)
    }
    
    public subscript (position: Int) -> TrackerSender {
        get {
            return senders[position]
        }
        set(newValue) {
            senders[position] = newValue
        }
    }
    
    public var startIndex: Int {
        return senders.startIndex
    }
    
    public var endIndex: Int {
        return senders.endIndex
    }
    
}
