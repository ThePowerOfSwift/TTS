//
//  GetUkrResponse.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 29/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public struct GetUkrResponse: Codable {
    
    public let response: [RepairPoint]
    
    public var cities: [NamedValue] {
        return Set(response.map { NamedValue(id: $0.city, name: $0.cityName) })
            .sorted(by: {$0.name < $1.name})
    }
    
}
