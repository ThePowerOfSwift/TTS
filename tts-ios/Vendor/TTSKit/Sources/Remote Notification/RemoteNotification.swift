//
//  RemoteNotification.swift
//  tts
//
//  Created by Dmitry Nesterenko on 20/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

/// Notification Payload Object
///
/// - See:
/// [Payload Key Reference](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/PayloadKeyReference.html)
public struct RemoteNotification {
    
    enum Error: Swift.Error {
        case missingApsKey
    }
    
    /// The aps dictionary contains the keys used by Apple to deliver the notification to the user’s device. The keys specify the type of interactions that you want the system to use when alerting the user.
    public struct Aps {
        
        public struct Alert {
            
            /// A short string describing the purpose of the notification. Apple Watch displays this string as part of the notification interface. This string is displayed only briefly and should be crafted so that it can be understood quickly. This key was added in iOS 8.2.
            public var title: String?

            /// The text of the alert message.
            public var body: String?
            
            /// The key to a title string in the Localizable.strings file for the current localization. The key string can be formatted with %@ and %n$@ specifiers to take the variables specified in the title-loc-args array. See Localized Formatted Strings for more information. This key was added in iOS 8.2.
            public var titleLocKey: String?

            /// Variable string values to appear in place of the format specifiers in title-loc-key. See Localized Formatted Strings for more information. This key was added in iOS 8.2.
            public var titleLocArgs: [String]?

            /// If a string is specified, the system displays an alert that includes the Close and View buttons. The string is used as a key to get a localized string in the current localization to use for the right button’s title instead of “View”. See Localized Formatted Strings for more information.
            public var actionLocKey: String?

            /// A key to an alert-message string in a Localizable.strings file for the current localization (which is set by the user’s language preference). The key string can be formatted with %@ and %n$@ specifiers to take the variables specified in the loc-args array. See Localized Formatted Strings for more information.
            public var locKey: String?

            /// Variable string values to appear in place of the format specifiers in loc-key. See Localized Formatted Strings for more information.
            public var locArgs: [String]?

            /// The filename of an image file in the app bundle; it may include the extension or omit it. The image is used as the launch image when users tap the action button or move the action slider. If this property is not specified, the system either uses the previous snapshot,uses the image identified by the UILaunchImageFile key in the app’s Info.plist file, or falls back to Default.png.
            public var launchImage: String?

            internal func localizedTitle(tableName: String? = nil, bundle: Bundle = .main) -> String? {
                if title != nil {
                    return title
                }
                
                if let locKey = self.locKey {
                    let format = NSLocalizedString(locKey, tableName: tableName, bundle: bundle, comment: "")
                    if let locArgs = self.locArgs {
                        return String(format: format, arguments: locArgs)
                    } else {
                        return format
                    }
                }
                
                if let titleLocKey = self.titleLocKey {
                    let format = NSLocalizedString(titleLocKey, tableName: tableName, bundle: bundle, comment: "")
                    if let titleLocArgs = self.titleLocArgs {
                        return String(format: format, arguments: titleLocArgs)
                    } else {
                        return format
                    }
                }
                
                return nil
            }
            
            public var localizedTitle: String? {
                return self.localizedTitle()
            }
            
            init(string: String) {
                title = string
            }
            
            init(dictionary: [AnyHashable: Any]) throws {
                if let value = dictionary["title"] as? String {
                    title = value
                }
                
                if let value = dictionary["body"] as? String {
                    body = value
                }

                if let value = dictionary["title-loc-key"] as? String {
                    titleLocKey = value
                }

                if let value = dictionary["title-loc-args"] as? [String] {
                    titleLocArgs = value
                }

                if let value = dictionary["action-loc-key"] as? String {
                    actionLocKey = value
                }
                
                if let value = dictionary["loc-key"] as? String {
                    locKey = value
                }
                
                if let value = dictionary["loc-args"] as? [String] {
                    locArgs = value
                }
                
                if let value = dictionary["launch-image"] as? String {
                    launchImage = value
                }
            }
            
        }
        
        /// Include this key when you want the system to display a standard alert or a banner. The notification settings for your app on the user’s device determine whether an alert or banner is displayed.
        ///
        /// The preferred value for this key is a dictionary. If you specify a string as the value of this key, that string is displayed as the message text of the alert or banner.
        ///
        /// The JSON \U notation is not supported. Put the actual UTF-8 character in the alert text instead.
        public var alert: Alert?
        
        /// Include this key when you want the system to modify the badge of your app icon.
        ///
        /// If this key is not included in the dictionary, the badge is not changed. To remove the badge, set the value of this key to 0.
        public var badge: Int?
        
        /// Include this key when you want the system to play a sound. The value of this key is the name of a sound file in your app’s main bundle or in the Library/Sounds folder of your app’s data container. If the sound file cannot be found, or if you specify defaultfor the value, the system plays the default alert sound.
        public var sound: String?
        
        /// Include this key with a value of 1 to configure a silent notification. When this key is present, the system wakes up your app in the background and delivers the notification to its app delegate.
        public var contentAvailable: Int?
        
        /// Provide this key with a string value that represents the notification’s type. This value corresponds to the value in the identifier property of one of your app’s registered categories.
        public var category: String?
        
        /// Provide this key with a string value that represents the app-specific identifier for grouping notifications. If you provide a Notification Content app extension, you can use this value to group your notifications together. For local notifications, this key corresponds to the threadIdentifier property of the UNNotificationContent object.
        public var threadId: String?
        
        init(dictionary: [AnyHashable: Any]) throws { // swiftlint:disable:this cyclomatic_complexity
            if let value = dictionary["alert"] {
                if let dictionary = value as? [AnyHashable: Any] {
                    alert = try Alert(dictionary: dictionary)
                } else if let string = value as? String {
                    alert = Alert(string: string)
                }
            }

            if let value = dictionary["badge"] {
                if let string = value as? String {
                    badge = NumberFormatter().number(from: string)?.intValue
                } else if let number = value as? Int {
                    badge = number
                }
            }

            if let value = dictionary["sound"] as? String {
                sound = value
            }

            if let value = dictionary["content-available"] {
                if let string = value as? String {
                    contentAvailable = NumberFormatter().number(from: string)?.intValue
                } else if let number = value as? Int {
                    contentAvailable = number
                }
            }
            
            if let value = dictionary["category"] as? String {
                category = value
            }
            
            if let value = dictionary["thread-id"] as? String {
                threadId = value
            }
        }
        
    }
    
    /// The aps dictionary contains the keys used by Apple to deliver the notification to the user’s device. The keys specify the type of interactions that you want the system to use when alerting the user.
    public var aps: Aps
    
    /// Custom payload values outside the Apple-reserved aps namespace.
    public var userInfo: [AnyHashable: Any]?
    
    public init(dictionary: [AnyHashable: Any]) throws {
        guard let aps = dictionary["aps"] as? [AnyHashable: Any] else {
            throw Error.missingApsKey
        }
        
        self.aps = try Aps(dictionary: aps)
        
        var userInfo = dictionary
        userInfo["aps"] = nil
        if userInfo.count > 0 {
            self.userInfo = userInfo
        }
    }
    
}
