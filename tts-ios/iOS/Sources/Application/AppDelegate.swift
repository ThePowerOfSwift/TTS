//
//  AppDelegate.swift
//  tts
//
//  Created by Dmitry Nesterenko on 25/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import GoogleMaps
import ThemeKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var coordinator: ApplicationCoordinator!
    private var notifications: NotificationsManager!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        
        GMSServices.provideAPIKey("AIzaSyA4sGJlMWpcUAd9Qst5bTotVnDF5ZHWjlM")
        
        notifications = NotificationsManager()
        
        if let path = Bundle.main.path(forResource: "Theme", ofType: "plist") {
            try? Theme().parsePlist(path: path)
        }
        
        // application coordinator
        coordinator = ApplicationCoordinator(window: window, notifications: notifications)
        return coordinator.launch()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        notifications.apnsToken = deviceToken
    }
    
}
