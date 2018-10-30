//
//  ResponseMapper.swift
//  tts
//
//  Created by Dmitry Nesterenko on 17/09/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public enum ResponseMapperError: LocalizedError {
    
    case emptyData
    
    case mappingFailed(underlying: Error)
    
    public var errorDescription: String? {
        switch self {
        case .emptyData:
            return "No data"
        case .mappingFailed(let underlying):
            return underlying.localizedDescription
        }
    }
    
    public var mappingFailedError: Error? {
        switch self {
        case .emptyData:
            return nil
        case .mappingFailed(let underlying):
            return underlying
        }
    }
    
}

public final class JSONResponseMapper<T: Decodable> : URLResponseMappable {
    
    public init() {}
    
    public func object(for response: HTTPURLResponse?, data: Data?) throws -> T {
        guard let data = data else { throw ResponseMapperError.emptyData }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw ResponseMapperError.mappingFailed(underlying: error)
        }
    }
    
}

final class StringResponseMapper: URLResponseMappable {
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> String {
        guard let data = data else { throw ResponseMapperError.emptyData }
        if let string = String(data: data, encoding: .utf8) {
            return string
        } else {
            throw ResponseMapperError.emptyData
        }
    }
    
}
