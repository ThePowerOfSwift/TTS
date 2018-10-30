//
//  OrderTechServiceGetDetailResponse.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 07/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public struct OrderTechServiceGetDetailResponse: Decodable {
    
    public struct Detail: Decodable {
        
        private enum CodingKeys: String, CodingKey {
            case uid
            case name
            case description
            case total
        }
        
        public let uid: String
        public let name: String
        public let description: [OrderTechServiceDetailDescription]
        public let total: TechServicePrice
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            uid         = try container.decode(String.self, forKey: .uid)
            name        = try container.decode(String.self, forKey: .name)
            description = try container.decode([OrderTechServiceDetailDescription].self, forKey: .description)
            total       = try container.decode(TechServicePrice.self, forKey: .total)
        }
        
    }
    
    private enum CodingKeys: String, CodingKey {
        case standard = "standart"
        case econom
    }
    
    public let standard: Detail?
    public let econom: Detail?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        standard = try container.decodeIfPresent(Detail.self, forKey: .standard)
        econom   = try container.decodeIfPresent(Detail.self, forKey: .econom)
    }
    
}
