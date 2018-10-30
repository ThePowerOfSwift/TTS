//
//  NotificationsManager.swift
//  tts
//
//  Created by Dmitry Nesterenko on 11/07/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import UserNotifications
import Firebase
import RxSwift
import TTSKit

final class NotificationsManager: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let messaging: Messaging
    
    override init() {
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        messaging = Messaging.messaging()
        
        super.init()
        
        notificationCenter.delegate = self
        messaging.delegate = self
    }
    
    var apnsToken: Data? {
        get {
            return messaging.apnsToken
        }
        set {
            messaging.apnsToken = newValue
        }
    }
    
    func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func requestAuthorization() -> Completable {
        return Completable.create(subscribe: { [notificationCenter] subscription -> Disposable in
            let options: UNAuthorizationOptions = [.alert, .badge, .sound]
            notificationCenter.requestAuthorization(options: options, completionHandler: { granted, error in
                if granted {
                    subscription(.completed)
                } else {
                    subscription(.error(error ?? RxError.unknown))
                }
            })
            return Disposables.create()
        })
    }
    
    func fetchFirebaseInstanceID() -> Single<InstanceIDResult> {
        return Single.create { subscription -> Disposable in
            InstanceID.instanceID().instanceID { result, error in
                if let result = result {
                    subscription(.success(result))
                } else {
                    subscription(.error(error ?? RxError.unknown))
                }
            }
            return Disposables.create()
        }
    }
    
    // MARK: - Notification Center
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        // FCMToken is being provided bt the `NotificationsManager.fetchFirebaseInstanceID()` method
        // so this is just an empty implementation to silence following warning:
        // `[Firebase/Messaging][I-FCM002023] The object <tts.NotificationsManager: 0x60c00003c0e0> does not respond to -messaging:didReceiveRegistrationToken:. Please implement -messaging:didReceiveRegistrationToken: to be provided with an FCM token.`
    }
    
}
