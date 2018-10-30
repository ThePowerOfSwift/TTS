//
//  OrderTechServiceGetVariantsResponse.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public struct OrderTechServiceGetVariantsResponse: Decodable, Equatable {
    
    public struct Variant: Decodable, Equatable {
        
        private enum CodingKeys: String, CodingKey {
            case from
            case to
        }
        
        public let range: Range<Date>
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let dateTransformer = ServerDateTransformer()

            let from = try dateTransformer.date(from: try container.decode(String.self, forKey: .from))
            let to   = try dateTransformer.date(from: try container.decode(String.self, forKey: .to))
            range = from..<to
        }
        
    }
    
    private enum CodingKeys: String, CodingKey {
        case variants
        case next
    }
    
    public let variants: [Variant]
    public let next: Date
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let dateTransformer = ServerDateTransformer()
        
        variants = try container.decode([Variant].self, forKey: .variants)
        next     = try dateTransformer.date(from: try container.decode(String.self, forKey: .next))
    }
    
}
