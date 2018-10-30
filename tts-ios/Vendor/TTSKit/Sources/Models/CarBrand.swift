//
//  Brand.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 02/03/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public struct CarBrand: Codable {
    
    public let id: Int
    
    public let name: String
    
    public let image: URL?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id    = try container.decode(Int.self, forKey: .id)
        name  = try container.decode(String.self, forKey: .name)
        
        do {
            image = try container.decode(URL.self, forKey: .image)
        } catch {
            image = nil
        }
    }
    
}
