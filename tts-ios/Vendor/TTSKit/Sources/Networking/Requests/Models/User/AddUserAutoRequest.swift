//
//  AddUserAutoRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 02/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Добавление нового авто в гараж пользователя
struct AddUserAutoRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    
    let brandId: Int
    let modelId: Int
    let completationId: Int?
    let year: Int
    let gosnomer: String
    let vin: String
    let mileage: Int?
    let serviceId: String?
    
    init(brandId: Int, modelId: Int, completationId: Int?, year: Int, gosnomer: String, vin: String, mileage: Int?, serviceId: String?) {
        self.brandId = brandId
        self.modelId = modelId
        self.completationId = completationId
        self.year = year
        self.gosnomer = gosnomer
        self.vin = vin
        self.mileage = mileage
        self.serviceId = serviceId
    }
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/addUserAuto")
        var userAuto = [String: Any]()
        userAuto["brand_id"] = brandId
        userAuto["model_id"] = modelId
        userAuto["complectation_id"] = completationId
        userAuto["year"] = year
        userAuto["gosnomer"] = gosnomer
        userAuto["vin"] = vin
        userAuto["mileage"] = mileage
        userAuto["service_uid"] = serviceId
        let parameters = ["user_auto": userAuto]
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader, parameters: parameters)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<VoidResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
