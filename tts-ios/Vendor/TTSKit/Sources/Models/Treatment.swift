//
//  Treatment.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 18/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public struct Treatment: Codable, Equatable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case reason
        case type
        case summ
        case sale
        case accrued
        case deducted
        case master
        case masterPhoto = "master_photo"
        case ordernum
        case mileage
        case serviceCenter = "service_center"
    }
    
    /// ID обращения
    public let id: String
    
    /// Дата обращения
    public let date: Date
    
    /// Причина обращения
    public let reason: String
    
    /// Тип обращения
    public let type: String
    
    /// Окончательная оплата
    ///
    /// Сколько заплатил клиент
    public let summ: NSDecimalNumber
    
    /// Общая скидка с учетом бонусов
    public let sale: NSDecimalNumber
    
    /// Количество бонусов за обращение
    public let accrued: NSDecimalNumber
    
    /// Количество списанных бонусов
    public let deducted: NSDecimalNumber
    
    /// Мастер-приемщик
    public let master: String
    
    /// Фото мастера
    public let masterPhoto: URL
    
    /// Номер заказ-наряда
    public let ordernum: String
    
    /// Пробег автомобиля на момент обращения
    public let mileage: NSDecimalNumber
    
    public let serviceCenter: ServiceCenter?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let decimalTransformer = DecimalTransformer()
        
        id            = try container.decode(String.self, forKey: .id)
        date          = Date(timeIntervalSince1970: try container.decode(TimeInterval.self, forKey: .date))
        reason        = try container.decode(String.self, forKey: .reason)
        type          = try container.decode(String.self, forKey: .type)
        master        = try container.decode(String.self, forKey: .master)
        masterPhoto   = try container.decode(URL.self, forKey: .masterPhoto)
        ordernum      = try container.decode(String.self, forKey: .ordernum)
        serviceCenter = try container.decodeIfPresent(ServiceCenter.self, forKey: .serviceCenter)

        if let value = try? container.decode(Double.self, forKey: .summ) {
            summ = NSDecimalNumber(value: value)
        } else {
            let string = try container.decode(String.self, forKey: .summ)
            summ = try decimalTransformer.number(from: string)
        }
        
        if let value = try? container.decode(Double.self, forKey: .sale) {
            sale = NSDecimalNumber(value: value)
        } else {
            let string = try container.decode(String.self, forKey: .sale)
            sale = try decimalTransformer.number(from: string)
        }
        
        if let value = try? container.decode(Double.self, forKey: .accrued) {
            accrued = NSDecimalNumber(value: value)
        } else {
            let string = try container.decode(String.self, forKey: .accrued)
            accrued = try decimalTransformer.number(from: string)
        }

        if let value = try? container.decode(Double.self, forKey: .deducted) {
            deducted = NSDecimalNumber(value: value)
        } else {
            let string = try container.decode(String.self, forKey: .deducted)
            deducted = try decimalTransformer.number(from: string)
        }

        if let value = try? container.decode(Double.self, forKey: .mileage) {
            mileage = NSDecimalNumber(value: value)
        } else {
            let string = try container.decode(String.self, forKey: .mileage)
            mileage = try decimalTransformer.number(from: string)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(date.timeIntervalSince1970, forKey: .date)
        try container.encode(reason, forKey: .reason)
        try container.encode(type, forKey: .type)
        try container.encode(summ.stringValue, forKey: .summ)
        try container.encode(sale.stringValue, forKey: .sale)
        try container.encode(accrued.stringValue, forKey: .accrued)
        try container.encode(deducted.stringValue, forKey: .deducted)
        try container.encode(master, forKey: .master)
        try container.encode(masterPhoto, forKey: .masterPhoto)
        try container.encode(ordernum, forKey: .ordernum)
        try container.encode(mileage.stringValue, forKey: .mileage)
        try container.encodeIfPresent(serviceCenter, forKey: .serviceCenter)
    }
    
}
