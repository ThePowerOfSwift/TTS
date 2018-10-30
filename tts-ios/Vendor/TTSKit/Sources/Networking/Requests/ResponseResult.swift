//
//  ResponseResult.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 25/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public enum ResponseResultError: LocalizedError {
    
    case invalidErrorCode(code: Int, message: String?)
    
    public var errorDescription: String? {
        switch self {
        case .invalidErrorCode(let code, var message):
            let key = String(code)
            var localizedMessage: String? = NSLocalizedString(key, tableName: "ResponseResultError", bundle: Bundle(identifier: "com.dz.ttskit")!, comment: "")
            if localizedMessage == key {
                localizedMessage = nil
            }
            message = localizedMessage ?? message
            let numberOfCharacters = message?.count ?? 0
            return numberOfCharacters > 0 ? message : "Ошибка сервера (\(code))"
        }
    }
    
}

public struct ResponseResult<Value: Decodable> : Decodable {
    
    enum CodingKeys: String, CodingKey {
        case error
        case status
        case errorCode = "error_code"
        case errorMessage = "error_message"
    }
    
    public var error: Int?
    public var status: String?
    public var errorCode: Int?
    public var errorMessage: String?
    
    public var value: Value
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        error = try container.decodeIfPresent(Int.self, forKey: .error)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        
        // validate response result code
        if let error = error, error != 0 {
            errorCode = try container.decode(Int.self, forKey: .errorCode)
            errorMessage = try container.decode(String.self, forKey: .errorMessage)
            throw ResponseResultError.invalidErrorCode(code: errorCode!, message: errorMessage!)
        }
        
        value = try Value(from: decoder)
    }
    
}
