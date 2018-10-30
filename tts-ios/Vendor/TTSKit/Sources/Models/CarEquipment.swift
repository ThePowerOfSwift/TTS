//
//  CarEquipment.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 10/03/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public struct CarEquipment: Codable {
    
    public let id: String
    
    public let name: String
    
    public let uid: String
    
    public let brand: String
    
    public let model: String
    
    public let year_from: String
    
    public let year_to: String?
    
}
