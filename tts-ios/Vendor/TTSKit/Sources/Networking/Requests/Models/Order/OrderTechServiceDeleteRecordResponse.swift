//
//  OrderTechServiceDeleteRecordResponse.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 15/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public struct OrderTechServiceDeleteRecordResponse: Decodable {
    
    enum CodingKeys: CodingKey {
        
        case success
        
    }
    
    public let success: Bool
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let boolTransformer = BoolTransformer()
        
        if let string = try? container.decode(String.self, forKey: .success) {
            success = try boolTransformer.boolValue(fromString: string)
        } else if let int = try? container.decode(Int.self, forKey: .success) {
            success = try boolTransformer.boolValue(fromInt: int)
        } else {
            success = try container.decode(Bool.self, forKey: .success)
        }
    }
    
}
