//
//  TreatmentDetail.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 19/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Использованные материалы или проведенные работы
public struct TreatmentDetail: Codable, Equatable {
    
    enum CodingKeys: String, CodingKey {
        case name
        case amount
        case summ
        case type
    }
    
    /// Тип
    public enum `Type` : Equatable {
        
        /// неизвестный тип
        case unknown(rawValue: String)
        
        /// ном - номенклатура
        case nomenclature
        
        /// усл – услуга
        case job
        
        init(rawValue: String) {
            switch rawValue {
            case `Type`.job.rawValue:
                self = .job
            case `Type`.nomenclature.rawValue:
                self = .nomenclature
            default:
                self = .unknown(rawValue: rawValue)
            }
        }
        
        var rawValue: String {
            switch self {
            case .job:
                return "усл"
            case .nomenclature:
                return "ном"
            case .unknown(let rawValue):
                return rawValue
            }
        }
                
    }
    
    /// Наименование запчасти или наименование вида работ
    public let name: String
    
    /// Количество запчастей или количество нормо-часов
    public let amount: NSDecimalNumber
    
    /// Общая сумма
    public let summ: NSDecimalNumber
    
    /// Тип
    public let type: `Type`
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let decimalTransformer = DecimalTransformer()
        
        name = try container.decode(String.self, forKey: .name)
        type = Type(rawValue: try container.decode(String.self, forKey: .type))
        
        if let value = try? container.decode(Double.self, forKey: .amount) {
            amount = NSDecimalNumber(value: value)
        } else {
            let string = try container.decode(String.self, forKey: .amount)
            amount = try decimalTransformer.number(from: string)
        }
        
        if let value = try? container.decode(Double.self, forKey: .summ) {
            summ = NSDecimalNumber(value: value)
        } else {
            let string = try container.decode(String.self, forKey: .summ)
            summ = try decimalTransformer.number(from: string)
        }
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(amount.stringValue, forKey: .amount)
        try container.encode(summ.stringValue, forKey: .summ)
        try container.encode(type.rawValue, forKey: .type)
    }
    
}

extension Array where Element == TreatmentDetail {
    
    public var summ: NSDecimalNumber {
        return reduce(0, {$1.summ.adding($0)}) 
    }
    
}
