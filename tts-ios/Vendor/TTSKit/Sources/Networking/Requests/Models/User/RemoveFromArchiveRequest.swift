//
//  RemoveFromArchiveRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 12/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Запрос на удаление автомобиля из архива
struct RemoveFromArchiveRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    
    /// VIN – номер автомобиля
    let vin: String
    
    init(vin: String) {
        self.vin = vin
    }
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/removeFromArchive")
        var parameters = [String: Any]()
        parameters["vin"] = vin
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader, parameters: parameters)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<VoidResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
