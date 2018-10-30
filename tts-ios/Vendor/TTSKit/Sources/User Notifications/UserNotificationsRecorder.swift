//
//  UserNotificationsRecorder.swift
//  tts
//
//  Created by Dmitry Nesterenko on 18/08/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import UserNotifications

extension NSNotification.Name {
    
    /// Observe this notification to get informed when a new notification is received in a foreground
    ///
    /// Inspect `object` property to get `UNNotification` object.
    public static let UserNotificationCenterWillPresentNotification: NSNotification.Name = NSNotification.Name(rawValue: "UserNotificationCenterWillPresentNotification")
    
}

// This protocol is only for compatibility with iOS 9
// Delete it after iOS 9 droped
public protocol UserNotificationsRecording: class {
    
    var recordingEnabled: Bool { get set }
    
    var observers: UserNotificationsObservers { get set }
    
    func playback()
 
    func removeAll()
    
}

// This class is only for compatibility with iOS 9
// Delete it after iOS 9 droped
public class UserNotificationsRecorderEmpty: UserNotificationsRecording {
    
    public var recordingEnabled: Bool = true
    
    public var observers = UserNotificationsObservers()
    
    public init() { }
    
    public func playback() {
        
    }
    
    public func removeAll() {
        
    }
    
}

@available(iOS 10, *)
public class UserNotificationsRecorder: NSObject, UserNotificationsRecording, UNUserNotificationCenterDelegate {
    
    /// Should the notifications be recorded when received or should it be handled imediately
    public var recordingEnabled: Bool = true
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // post global notification and complete
        NotificationCenter.default.post(Notification(name: NSNotification.Name.UserNotificationCenterWillPresentNotification, object: notification, userInfo: nil))
        completionHandler([.sound, .alert])
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
        if recordingEnabled {
            record(response)
        } else {
            observers.handle(response)
        }
        completionHandler()
    }

    private var responses = [UNNotificationResponse]()
    
    public var observers = UserNotificationsObservers()
    
    public func record(_ response: UNNotificationResponse) {
        responses.append(response)
    }
    
    public func playback() {
        for response in responses {
            observers.handle(response)
        }
    }
    
    public func removeAll() {
        responses.removeAll()
    }
    
}
