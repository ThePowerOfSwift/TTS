//
//  GetServiceCenterResponse.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 25/03/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public struct GetServiceCenterResponse: Codable {
    
    public let services: [ServiceCenter]
    
}
