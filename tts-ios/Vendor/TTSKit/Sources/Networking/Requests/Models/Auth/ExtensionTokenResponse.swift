//
//  ExtensionTokenResponse.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 29/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public struct ExtensionTokenResponse: Codable {
    
    public let access_token: String
    
    public let extension_token: String
    
}
