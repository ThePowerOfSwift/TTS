//
//  Tracker.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

/// Events sender object
public protocol TrackerSender {
    
    func activate()
    
    func accept(_ event: TrackerEvent) -> Bool
    
    func send(_ event: TrackerEvent)
    
    func applicationDidBecomeActive()
    
    func continueUserActivity(_ userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void)
    
    func openUrl(_ url: URL, options: [UIApplication.OpenURLOptionsKey: Any])
    
}

/// Interface that allows track events to be sended using an events sender object.
public final class Tracker {
    
    let sender: TrackerSender
    
    public var isEnabled: Bool = true
    
    public init(sender: TrackerSender) {
        self.sender = sender
    }
    
    public func activate() {
        guard isEnabled else { return }
        sender.activate()
    }
    
    public func track(_ event: TrackerEvent) {
        guard isEnabled else { return }
        
        if sender.accept(event) {
            sender.send(event)
        }
    }
    
    public func applicationDidBecomeActive() {
        guard isEnabled else { return }
        
        sender.applicationDidBecomeActive()
    }
    
    public func continueUserActivity(_ userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) {
        guard isEnabled else { return }
        
        sender.continueUserActivity(userActivity, restorationHandler: restorationHandler)
    }
    
    public func openUrl(_ url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) {
        guard isEnabled else { return }
        
        sender.openUrl(url, options: options)
    }
    
}
