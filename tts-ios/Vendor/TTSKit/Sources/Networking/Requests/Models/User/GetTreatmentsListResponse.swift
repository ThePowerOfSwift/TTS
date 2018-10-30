//
//  GetTreatmentsListResponse.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 18/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public struct GetTreatmentsListResponse: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case auto
    }
    
    private struct Treatments: Codable {
        let treatments: [Treatment]?
    }
    
    public let auto: [UserAuto]
    public let treatments: [String: [Treatment]]
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let auto = try container.decode([UserAuto].self, forKey: .auto)
        self.auto = auto
        
        let objects = try container.decode([Treatments].self, forKey: .auto)
        treatments = zip(0..<objects.count, objects).reduce(into: [String: [Treatment]](), {
            let (index, object) = $1
            $0[auto[index].id] = object.treatments ?? []
        })
    }
    
    public func treatments(with autoId: String) -> [Treatment]? {
        return treatments[autoId]
    }
    
}
