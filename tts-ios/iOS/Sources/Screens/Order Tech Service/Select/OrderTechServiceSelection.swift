//
//  OrderTechServiceSelection.swift
//  tts
//
//  Created by Dmitry Nesterenko on 25/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import TTSKit

enum OrderTechServiceSelection {
    
    case techService(OrderTechServiceGetListResponse.Service, OrderTechServiceGetDetailResponse.Detail, String?)
    
    case otherWork(String)
    
    var kind: TechServiceOrderKind {
        switch self {
        case .otherWork(let otherWork):
            return .otherWork(otherWork)
        case .techService(let techService, let detail, let otherWork):
            return .techService(tsUid: techService.uid, typeUid: detail.uid, otherWork: otherWork)
        }
    }
    
    var description: String {
        switch self {
        case .otherWork(let otherWork):
            return otherWork
        case .techService(let techService, let detail, _):
            let strings = [techService.name] + detail.description.map { $0.operation }
            return strings.joined(separator: "\n")
        }
    }
    
    var price: TechServicePrice {
        switch self {
        case .otherWork:
            return .unknown
        case .techService(_, let detail, _):
            return detail.total
        }
    }
}
