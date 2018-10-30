//
//  Paginator.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import RxSwift

public class Paginator<Service: PaginatorService> {
    
    enum Page {
        
        case none
        
        case number(Int)
        
        func next() -> Int {
            switch self {
            case .none:
                return 0
            case .number(let page):
                return page + 1
            }
        }
        
    }
    
    let service: Service
    
    let size: Int
    
    private(set) var page: Page = .none
    
    public init(service: Service, size: Int) {
        self.service = service
        self.size = size
    }
    
    public func reset() {
        page = .none
    }
    
    public func next() -> Single<[Service.T]> {
        let page = self.page.next()
        return service.getPage(page, size: size).do(onSuccess: { [weak self] response in
            if response.count > 0 {
                self?.page = .number(page)
                self?.service.insert(contentsOf: response, at: page)
            }
            }, onError: { [weak self] error in
                self?.service.error(error, at: page)
        })
    }
    
}
