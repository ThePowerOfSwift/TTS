//
//  UserNotificationObserver.swift
//  tts
//
//  Created by Dmitry Nesterenko on 18/08/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import UserNotifications

public protocol UserNotificationObserver {
    
    @available(iOS 10, *)
    func accept(_ response: UNNotificationResponse) -> Bool
    
    @available(iOS 10, *)
    func handle(_ response: UNNotificationResponse)
    
}

public final class UserNotificationsObservers: UserNotificationObserver {
    
    public var observers: [UserNotificationObserver]
    
    required public init() {
        self.observers = []
    }
    
    // MARK: Observing

    @available(iOS 10, *)
    public func accept(_ response: UNNotificationResponse) -> Bool {
        return true
    }
    
    @available(iOS 10, *)
    public func handle(_ response: UNNotificationResponse) {
        if let observer = observers.first(where: {$0.accept(response)}) {
            observer.handle(response)
        }
    }
    
}

extension UserNotificationsObservers: RangeReplaceableCollection {
    
    // MARK: Collection
    
    public var startIndex: Int {
        return observers.startIndex
    }
    
    public var endIndex: Int {
        return observers.endIndex
    }
    
    public subscript (position: Int) -> UserNotificationObserver {
        return observers[position]
    }
    
    public func index(after i: Int) -> Int {
        return observers.index(after: i)
    }
    
    // MARK: Range Replaceable Collection
    
    public convenience init<S: Sequence>(_ elements: S) where S.Element == UserNotificationObserver {
        self.init()
        observers.append(contentsOf: elements)
    }
    
    public func append<S>(contentsOf newElements: S) where S: Sequence, UserNotificationObserver == S.Element {
        observers.append(contentsOf: newElements)
    }
    
    public func replaceSubrange<C, R>(_ subrange: R, with newElements: C) where C: Collection, R: RangeExpression, UserNotificationObserver == C.Element, Int == R.Bound {
        observers.replaceSubrange(subrange, with: newElements)
    }
    
}
