//
//  URLRequestSerializer.swift
//  tts
//
//  Created by Dmitry Nesterenko on 08/09/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import Alamofire

final class URLRequestSerializer {
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    var encoding = JSONEncoding.default
    
    func request(url: URL, method: HTTPMethod = .get, headers: [String: String]? = nil, parameters: [String: Any]? = nil) throws -> Foundation.URLRequest {
        var request = Foundation.URLRequest(url: url)
        
        request.httpMethod = method.rawValue
        
        if let headers = headers {
            for (headerField, headerValue) in headers {
                request.setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
        
        return try encoding.encode(request, with: parameters)
    }
    
}
