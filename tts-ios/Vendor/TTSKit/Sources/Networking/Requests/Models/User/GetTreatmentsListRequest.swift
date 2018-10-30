//
//  GetTreatmentsListRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 18/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Список обращений сгруппированных по авто
struct GetTreatmentsListRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/getTreatmentsList")
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<GetTreatmentsListResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
