//
//  TechServiceRecord.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 08/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public struct TechServiceRecord: Codable, Equatable {
    
    enum CodingKeys: CodingKey {
        case id
        case from
        case to
        case name
        case master
        case detail
        case auto
        case service
    }
    
    public struct Detail: Codable, Equatable {
        
        enum CodingKeys: CodingKey {
            case description
            case total
        }
        
        public let description: [OrderTechServiceDetailDescription]
        public let total: TechServicePrice
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            description = try container.decode([OrderTechServiceDetailDescription].self, forKey: .description)
            total       = try container.decode(TechServicePrice.self, forKey: .total)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(description, forKey: .description)
            try container.encode(total, forKey: .total)
        }
        
    }
    
    public struct Auto: Codable, Equatable {
        let id: String
        let brand: String
        let model: String
    }
    
    public let id: String
    public let period: Range<Date>
    public let name: String?
    public let master: String
    public let detail: Detail?
    public let auto: Auto
    public let service: ServiceCenter
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let dateTransformer = ServerDateTransformer()
        
        name    = try container.decodeIfPresent(String.self, forKey: .name)
        master  = try container.decode(String.self, forKey: .master)
        auto    = try container.decode(Auto.self, forKey: .auto)
        service = try container.decode(ServiceCenter.self, forKey: .service)

        if let value = try? container.decode(Int.self, forKey: .id) {
            id = String(value)
        } else {
            id = try container.decode(String.self, forKey: .id)
        }
        
        do {
            if try container.decode(Bool.self, forKey: .detail) == false {
                detail = nil
            } else {
                throw DecodingError.dataCorruptedError(forKey: .detail, in: container, debugDescription: "Can't assign bool `true` value for `detail` key")
            }
        } catch {
            detail = try container.decodeIfPresent(Detail.self, forKey: .detail)
        }
        
        let from    = try dateTransformer.date(from: try container.decode(String.self, forKey: .from))
        let to      = try dateTransformer.date(from: try container.decode(String.self, forKey: .to))
        if to < from {
            throw DecodingError.dataCorruptedError(forKey: .from, in: container, debugDescription: "Invalid range bounds \(from) !< \(to)")
        }
        period = from..<to
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let dateTransformer = ServerDateTransformer()
        
        try container.encode(id, forKey: .id)
        try container.encode(dateTransformer.string(from: period.lowerBound), forKey: .from)
        try container.encode(dateTransformer.string(from: period.upperBound), forKey: .to)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encode(master, forKey: .master)
        try container.encode(auto, forKey: .auto)
        try container.encode(service, forKey: .service)
        
        if let detail = detail {
            try container.encode(detail, forKey: .detail)
        } else {
            try container.encode(false, forKey: .detail)
        }
    }
    
}
