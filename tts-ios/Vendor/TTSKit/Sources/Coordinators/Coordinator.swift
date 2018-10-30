//
//  Coordinator.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 27/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

open class Coordinator {
    
    private var coordinators = [Coordinator]()
    
    public init() {}
    
    public func add(_ coordinator: Coordinator) {
        coordinators.append(coordinator)
    }
    
    @discardableResult
    public func remove(_ coordinator: Coordinator) -> Coordinator? {
        guard let index = coordinators.index(where: { $0 === coordinator }) else {
            return nil
        }
        
        return coordinators.remove(at: index)
    }
    
}
