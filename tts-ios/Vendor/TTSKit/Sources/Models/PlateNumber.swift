//
//  PlateNumber.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 11/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public struct PlateNumber: Codable, RawRepresentable, Equatable {
    
    public var rawValue: String
    
    public let number: String
    
    public let region: String
    
    public init?(rawValue: String) {
        let string = rawValue.replacing(charactersIn: .whitespaces, with: "")
        guard let index = string.index(string.startIndex, offsetBy: 6, limitedBy: string.endIndex) else { return nil }
        self.rawValue = rawValue
        number = String(string[string.startIndex..<index])
        region = String(string[index..<string.endIndex])
    }
    
}
