//
//  BundleVersion.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public struct BundleVersion: Codable, Equatable {
    
    public var appVersion: String?
    
    public var buildNumber: String
    
    public init(appVersion: String?, buildNumber: String) {
        self.appVersion = appVersion
        self.buildNumber = buildNumber
    }
    
}
