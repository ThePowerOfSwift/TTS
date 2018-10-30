//
//  OrderTechServiceSendOrderRequest.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 21/05/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

/// Запрос записи на ТО
/// Получение вариантов времени для записи на ТО и времени для запроса следующих диапазонов
struct OrderTechServiceSendOrderRequest: NetworkRequest, AccessTokenIdentifiable {
    
    var accessToken: String?
    var autoUid: String
    var serviceUid: String
    var kind: TechServiceOrderKind
    var date: Date
    
    init(autoUid: String, serviceUid: String, kind: TechServiceOrderKind, date: Date) {
        self.autoUid = autoUid
        self.serviceUid = serviceUid
        self.kind = kind
        self.date = date
    }
    
    func request(with baseURL: URL) throws -> Foundation.URLRequest {
        let url = baseURL.appendingPathComponent("/order/techService/sendOrder")
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.autoupdatingCurrent
        
        var parameters = [String: Any]()
        parameters["auto_uid"] = autoUid
        parameters["service_uid"] = serviceUid
        
        switch kind {
        case .otherWork(let otherWork):
            parameters["other_work"] = otherWork
        case .techService(let tsUid, let typeUid, let otherWork):
            parameters["ts_uid"] = tsUid
            parameters["type_uid"] = typeUid
            parameters["other_work"] = otherWork
        }
        
        formatter.dateFormat = "dd.MM.y"
        parameters["date"] = formatter.string(from: date)
        
        formatter.dateFormat = "HH:mm"
        parameters["time"] = formatter.string(from: date)
        return try URLRequestSerializer().request(url: url, method: .post, headers: accessTokenHeader, parameters: parameters)
    }
    
    func object(for response: HTTPURLResponse?, data: Data?) throws -> ResponseResult<OrderTechServiceSendOrderResponse> {
        return try JSONResponseMapper().object(for: response, data: data)
    }
    
}
