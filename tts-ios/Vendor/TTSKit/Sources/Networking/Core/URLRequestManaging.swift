//
//  URLRequestManaging.swift
//  tts
//
//  Created by Dmitry Nesterenko on 08/09/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import RxSwift

public protocol URLRequestManaging {
    
    var baseURL: URL { get }
    
    func execute<Request: NetworkRequest>(_ request: Request) -> Single<Request.ResponseObject>
    
    func upload<Request: Uploadable>(_ request: Request, progress: ((Progress) -> Void)?) -> Single<Request.ResponseObject>
    
}
