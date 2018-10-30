//
//  URLRequest.swift
//  tts
//
//  Created by Dmitry Nesterenko on 08/09/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public protocol URLRequestConvertible {
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest
    
}

public protocol URLResponseValidatable {
    
    func validate(_ response: HTTPURLResponse?, data: Data?, error: Swift.Error?) throws
    
}

extension URLResponseValidatable {
    
    public func validate(_ response: HTTPURLResponse?, data: Data?, error: Swift.Error?) throws {
        // do nothing
    }
    
}

public protocol URLResponseMappable {
    
    associatedtype ResponseObject
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseObject
    
}

public protocol NetworkRequest: URLRequestConvertible, URLResponseValidatable, URLResponseMappable {
    
}
