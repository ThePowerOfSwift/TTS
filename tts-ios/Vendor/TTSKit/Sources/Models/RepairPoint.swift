//
//  RepairPoint.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 19/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public struct RepairPoint: Codable {
    
    enum CodingKeys: String, Swift.CodingKey {
        case id
        case name
        case city
        case cityName = "city_name"
        case email
        case uid
        case image
        case moreImages = "more_images"
    }
    
    public let id: Int
    public let name: String
    public let city: Int
    public let cityName: String
    public let email: [String]
    public let uid: String
    public let image: URL
    public let moreImages: [URL]?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id         = try container.decode(Int.self, forKey: .id)
        name       = try container.decode(String.self, forKey: .name)
        city       = try container.decode(Int.self, forKey: .city)
        cityName   = try container.decode(String.self, forKey: .cityName)
        email      = try container.decode(String.self, forKey: .email).components(separatedBy: ",").map {$0.trimmingCharacters(in: .whitespaces)}
        uid        = try container.decode(String.self, forKey: .uid)
        image      = try container.decode(URL.self, forKey: .image)
        moreImages = try container.decodeIfPresent([URL].self, forKey: .moreImages)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(city, forKey: .city)
        try container.encode(cityName, forKey: .cityName)
        try container.encode(email.joined(separator: ","), forKey: .email)
        try container.encode(uid, forKey: .uid)
        try container.encode(image, forKey: .image)
        try container.encodeIfPresent(moreImages, forKey: .moreImages)
    }
    
}
