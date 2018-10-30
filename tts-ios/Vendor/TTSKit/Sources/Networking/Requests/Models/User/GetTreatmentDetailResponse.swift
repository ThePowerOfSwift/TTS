//
//  GetTreatmentDetailResponse.swift
//  Tests
//
//  Created by Dmitry Nesterenko on 20/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public struct GetTreatmentDetailResponse: Codable, Equatable {
    
    enum CodingKeys: String, CodingKey {
        case treatment
        case nomenclature
        case jobs
    }
    
    private struct Details: Codable {
        let nomenclature: [TreatmentDetail]?
        let jobs: [TreatmentDetail]?
    }
    
    public let treatment: Treatment?
    public let nomenclature: [TreatmentDetail]?
    public let jobs: [TreatmentDetail]?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        treatment = try container.decode(Treatment.self, forKey: .treatment)
        
        let details = try container.decode(Details.self, forKey: .treatment)
        nomenclature = try container.decodeIfPresent([TreatmentDetail].self, forKey: .nomenclature) ?? details.nomenclature
        jobs = try container.decodeIfPresent([TreatmentDetail].self, forKey: .jobs) ?? details.jobs
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(treatment, forKey: .treatment)
        try container.encodeIfPresent(nomenclature, forKey: .nomenclature)
        try container.encodeIfPresent(jobs, forKey: .jobs)
    }
    
}
