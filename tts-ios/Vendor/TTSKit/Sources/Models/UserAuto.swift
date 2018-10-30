//
//  UserAuto.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 02/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public struct UserAuto: Codable, Equatable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case brand
        case brandId = "brand_id"
        case model
        case year
        case mileage
        case gosnomer
        case vin
        case complectation
        case upload1c = "1c"
        case nextToDate = "next_to_date"
        case nextKaskoDate = "next_kasko_date"
        case nextOsagoDate = "next_osago_date"
        case image
        case serviceCenter = "service_center"
        case brandImage = "brand_image"
        case records
    }
    
    /// ID автомобиля
    public let id: String
    
    /// Бренд
    public let brand: String
    
    public let brandId: Int?
    
    /// Модель
    public let model: String
    
    /// Год выпуска
    public let year: String
    
    /// Пробег
    public let mileage: NSDecimalNumber
    
    /// Гос номер
    public let gosnomer: PlateNumber?
    
    /// VIN-номер
    public let vin: String
    
    /// Комплектация
    public let complectation: String?
    
    public let upload1c: Bool
    
    /// Дата следующего ТО
    public let nextToDate: Date?
    
    /// Дата истечения КАСКО
    public let nextKaskoDate: Date?
    
    /// Дата истечения ОСАГО
    public let nextOsagoDate: Date?
    
    /// Изображение авто
    public let image: URL
    
    /// Данные сервисного центра к которому привязан автомобиль (если привязка существует)
    public let serviceCenter: ServiceCenter?
 
    public let brandImage: URL?
    
    /// Список записей на ТО для данного автомобиля.
    public let records: [TechServiceRecord]?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id            = try container.decode(String.self, forKey: .id)
        brand         = try container.decode(String.self, forKey: .brand)
        brandId       = try container.decodeIfPresent(Int.self, forKey: .brandId)
        model         = try container.decode(String.self, forKey: .model)
        vin           = try container.decode(String.self, forKey: .vin)
        complectation = try container.decodeIfPresent(String.self, forKey: .complectation)
        nextToDate    = try container.decodeIfPresent(Date.self, forKey: .nextToDate)
        nextKaskoDate = try container.decodeIfPresent(Date.self, forKey: .nextKaskoDate)
        nextOsagoDate = try container.decodeIfPresent(Date.self, forKey: .nextOsagoDate)
        image         = try container.decode(URL.self, forKey: .image)
        serviceCenter = try container.decodeIfPresent(ServiceCenter.self, forKey: .serviceCenter)
        records       = try container.decodeIfPresent([TechServiceRecord].self, forKey: .records)

        do {
            brandImage = try container.decode(URL.self, forKey: .brandImage)
        } catch {
            brandImage = nil
        }

        if let int = try? container.decode(Int.self, forKey: .year) {
            year = String(int)
        } else {
            year = try container.decode(String.self, forKey: .year)
        }
        
        if let int = try? container.decode(Int.self, forKey: .mileage) {
            mileage = NSDecimalNumber(value: int)
        } else {
            let string = try container.decode(String.self, forKey: .mileage)
            mileage = try DecimalTransformer().number(from: string)
        }
        
        let boolTransformer = BoolTransformer()
        
        if let string = try? container.decode(String.self, forKey: .upload1c) {
            upload1c = try boolTransformer.boolValue(fromString: string)
        } else if let int = try? container.decode(Int.self, forKey: .upload1c) {
            upload1c = try boolTransformer.boolValue(fromInt: int)
        } else {
            upload1c = try container.decode(Bool.self, forKey: .upload1c)
        }
        
        if let string = try container.decodeIfPresent(String.self, forKey: .gosnomer) {
            gosnomer = try? PlateNumberTransformer().plateNumberFromString(for: string)
        } else {
            gosnomer = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(brand, forKey: .brand)
        try container.encodeIfPresent(brandId, forKey: .brandId)
        try container.encode(model, forKey: .model)
        try container.encode(year, forKey: .year)
        try container.encode(mileage.stringValue, forKey: .mileage)
        try container.encodeIfPresent(gosnomer, forKey: .gosnomer)
        try container.encode(vin, forKey: .vin)
        try container.encodeIfPresent(complectation, forKey: .complectation)
        try container.encode(upload1c, forKey: .upload1c)
        try container.encodeIfPresent(nextToDate, forKey: .nextToDate)
        try container.encodeIfPresent(nextKaskoDate, forKey: .nextKaskoDate)
        try container.encodeIfPresent(nextOsagoDate, forKey: .nextOsagoDate)
        try container.encode(image, forKey: .image)
        try container.encodeIfPresent(serviceCenter, forKey: .serviceCenter)
        try container.encode(brandImage, forKey: .brandImage)
        try container.encodeIfPresent(records, forKey: .records)
    }
    
}
