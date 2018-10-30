//
//  ServiceCenter.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 02/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation
import CoreLocation

private let kCoordinateFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.decimalSeparator = "."
    return formatter
}()

public struct ServiceCenter: Codable, Equatable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case address
        case phone
        case coordinatesLongitude = "coordinates_longitude"
        case coordinatesLatitude = "coordinates_latitude"
        case workingTime = "working_time"
        case recipients
        case cityId = "city_id"
        case cityName = "city_name"
        case uid
        case image
        case moreImages = "more_images"
        case brandId = "brand_id"
        case brandName = "brand_name"
        case brandImage = "brand_image"
        case isBind
        case auto
        case serviceList = "service_list"
    }
    
    /// ID сервисного центра
    public let id: Int
    
    /// Наименование сервисного центра
    public let name: String?
    
    /// Адрес сервисного центра
    public let address: String
    
    /// Номер телефона СЦ
    public let phone: [PhoneNumber]
    
    public let coordinatesLongitude: String
    
    public let coordinatesLatitude: String
    
    /// Координаты расположения СЦ на карте
    public var coordinate: CLLocationCoordinate2D {
        let latitude = kCoordinateFormatter.number(from: coordinatesLatitude)!
        let longitude = kCoordinateFormatter.number(from: coordinatesLongitude)!
        return CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
    }

    /// Время работы (массив строк)
    public let workingTime: [String]
    
    /// Email-ы получателей заявок СЦ
    public let recipients: String?
    
    /// ID города
    public let cityId: Int
    
    /// Наименование города
    public let cityName: String
    
    public let uid: String
    
    public let image: URL
    
    public let moreImages: [URL]?
    
    public let brandId: Int?
    
    /// Бренд который обслуживается в данном СЦ (all – все бренды, СЦ постгарантийного обслуживания)
    public let brandName: String?
    
    public let brandImage: URL?
    
    /// true — если к сервисному центру привязано авто (свойство `auto` будет содержать это авто)
    public let isBind: Bool?
    
    /// Список авто, привязанных к сервисному центру
    ///
    /// Возвращаются только на запрос getServiceCenterGroup
    public var auto: [UserAutoLight]?
    
    public let serviceList: [String]?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id          = try container.decode(Int.self, forKey: .id)
        name        = try container.decodeIfPresent(String.self, forKey: .name)
        address     = try container.decode(String.self, forKey: .address)
        phone       = try container.decode(String.self, forKey: .phone).components(separatedBy: ",").compactMap { try? PhoneNumber($0)}
        workingTime = try container.decode([String].self, forKey: .workingTime)
        cityId      = try container.decode(Int.self, forKey: .cityId)
        cityName    = try container.decode(String.self, forKey: .cityName)
        uid         = try container.decode(String.self, forKey: .uid)
        image       = try container.decode(URL.self, forKey: .image)
        moreImages  = try container.decodeIfPresent([URL].self, forKey: .moreImages)
        brandId     = try container.decodeIfPresent(Int.self, forKey: .brandId)
        brandName   = try container.decodeIfPresent(String.self, forKey: .brandName)
        isBind      = try container.decodeIfPresent(Bool.self, forKey: .isBind)
        auto        = try container.decodeIfPresent([UserAutoLight].self, forKey: .auto)
        serviceList = try container.decode([String].self, forKey: .serviceList)
        
        if try container.decodeNil(forKey: .recipients) {
            recipients = nil
        } else {
            recipients = try container.decode(String.self, forKey: .recipients)
        }
        
        do {
            brandImage = try container.decode(URL.self, forKey: .brandImage)
        } catch {
            brandImage = nil
        }
        
        coordinatesLongitude = try container.decode(String.self, forKey: .coordinatesLongitude)
        coordinatesLatitude  = try container.decode(String.self, forKey: .coordinatesLatitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encode(address, forKey: .address)
        try container.encode(phone.map {PhoneNumberFormatter().string(from: $0)}.joined(separator: ", "), forKey: .phone)
        try container.encode(workingTime, forKey: .workingTime)
        try container.encode(recipients, forKey: .recipients)
        try container.encode(cityId, forKey: .cityId)
        try container.encode(cityName, forKey: .cityName)
        try container.encode(uid, forKey: .uid)
        try container.encode(image, forKey: .image)
        try container.encodeIfPresent(moreImages, forKey: .moreImages)
        try container.encodeIfPresent(brandId, forKey: .brandId)
        try container.encodeIfPresent(brandName, forKey: .brandName)
        try container.encodeIfPresent(brandImage, forKey: .brandImage)
        try container.encode(coordinatesLongitude, forKey: .coordinatesLongitude)
        try container.encode(coordinatesLatitude, forKey: .coordinatesLatitude)
        try container.encodeIfPresent(isBind, forKey: .isBind)
        try container.encodeIfPresent(auto, forKey: .auto)
        try container.encode(serviceList, forKey: .serviceList)
    }
    
}

extension Array where Element == ServiceCenter {
    
    public func contains(brand: CarBrand?, city: NamedValue?) -> Bool {
        guard city != nil || brand != nil else { return true }
        return contains {
            var isBrandEqual = true, isCityEqual = true
            if let brand = brand {
                isBrandEqual = $0.brandId == brand.id
            }
            if let city = city {
                isCityEqual = $0.cityId == city.id
            }
            return isBrandEqual && isCityEqual
        }
    }
    
}
