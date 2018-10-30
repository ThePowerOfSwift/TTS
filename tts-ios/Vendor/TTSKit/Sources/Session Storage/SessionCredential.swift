//
//  SessionCredential.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 29/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public struct SessionCredential: Codable {
    
    public let accessToken: String
    public let extensionToken: String
    public let createDate: Date
    
    public init(accessToken: String, extensionToken: String) {
        self.accessToken = accessToken
        self.extensionToken = extensionToken
        self.createDate = Date()
    }
    
}
