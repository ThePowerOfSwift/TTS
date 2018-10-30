//
//  GetTreatmentDetailRequest.swift
//  Tests
//
//  Created by Dmitry Nesterenko on 20/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Подробная информация по обращению по ID обращения
struct GetTreatmentDetailRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    
    /// ID обращения полученный в запросе getTreatmentsByAuto
    let treatmentId: String
    
    init(treatmentId: String) {
        self.treatmentId = treatmentId
    }
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/getTreatmentDetail")
        var parameters = [String: Any]()
        parameters["treatment_uid"] = treatmentId
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader, parameters: parameters)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<GetTreatmentDetailResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
