//
//  PaginatorService.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import RxSwift

public protocol PaginatorService {
    
    associatedtype T
    
    func getPage(_ page: Int, size: Int) -> Single<[T]>
    
    func insert(contentsOf objects: [T], at: Int)
    
    func error(_ error: Error, at: Int)
    
}
