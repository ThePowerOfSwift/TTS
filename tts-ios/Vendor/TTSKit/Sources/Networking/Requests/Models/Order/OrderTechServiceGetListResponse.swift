//
//  OrderTechServiceGetListResponse.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 05/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public struct OrderTechServiceGetListResponse: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case to
        case toRecommend = "to_recommend"
        case date
        case mileage
    }
    
    public struct Service: Codable {
        public let uid: String
        public let name: String
        
        public var title: String {
            guard let index = name.index(of: "(") else { return name }
            return String(name.prefix(upTo: index))
        }
        
        public var date: String? {
            guard let index = name.index(of: "("), let startIndex = name.index(index, offsetBy: 1, limitedBy: name.endIndex), let endIndex = name.range(of: "или", options: [], range: startIndex..<name.endIndex)?.upperBound else { return nil }
            
            return String(name[startIndex..<endIndex]).trimmingCharacters(in: CharacterSet.whitespaces)
        }
        
        public var mileage: String? {
            guard let range = name.range(of: "или", options: []), let endIndex = name.range(of: ")", options: [], range: range.upperBound..<name.endIndex)?.lowerBound else { return nil }
            
            return String(name[range.upperBound..<endIndex].trimmingCharacters(in: CharacterSet.whitespaces))
        }
        
    }
    
    public let to: [Service]
    public let toRecommend: String?
    public let date: String?
    public let mileage: Measurement<UnitLength>?
    
    public var toRecommendService: Service? {
        return to.first { $0.uid == toRecommend } ?? to.last
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        to          = try container.decode([Service].self, forKey: .to)
        toRecommend = try container.decodeIfPresent(String.self, forKey: .toRecommend)
        date        = try container.decodeIfPresent(String.self, forKey: .date)
        mileage     = try container.decodeIfPresent(Int.self, forKey: .mileage).flatMap { Measurement(value: Double($0), unit: UnitLength.kilometers) }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(to, forKey: .to)
        try container.encodeIfPresent(toRecommend, forKey: .toRecommend)
        try container.encodeIfPresent(date, forKey: .date)
        try container.encodeIfPresent(mileage, forKey: .mileage)
    }
    
}
