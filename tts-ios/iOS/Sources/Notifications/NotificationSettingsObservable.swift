//
//  NotificationSettingsObservable.swift
//  tts
//
//  Created by Dmitry Nesterenko on 11/07/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import RxSwift
import UserNotifications

public final class NotificationSettingsObservable: ObservableType {
    
    public typealias E = UNNotificationSettings
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    public func subscribe<O>(_ observer: O) -> Disposable where O: ObserverType, NotificationSettingsObservable.E == O.E {
        // initial value
        notificationCenter.getNotificationSettings {
            observer.onNext($0)
        }
        
        // observe for app settings changes
        let observation = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { [notificationCenter] _ in
            notificationCenter.getNotificationSettings {
                observer.onNext($0)
            }
        }
        
        return Disposables.create {
            NotificationCenter.default.removeObserver(observation)
        }
    }
    
}
