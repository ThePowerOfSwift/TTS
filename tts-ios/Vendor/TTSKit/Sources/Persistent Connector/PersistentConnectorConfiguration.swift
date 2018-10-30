//
//  PersistentConnectorConfiguration.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 23/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public struct PersistentConnectorConfiguration {
    
    public let automaticallyMergesChangesFromParentToViewContext: Bool
    
    public let destroyPersistentStoresOnErrorDuringLoad: Bool
    
    public init(automaticallyMergesChangesFromParentToViewContext: Bool = true, destroyPersistentStoresOnErrorDuringLoad: Bool = true) {
        self.automaticallyMergesChangesFromParentToViewContext = automaticallyMergesChangesFromParentToViewContext
        self.destroyPersistentStoresOnErrorDuringLoad = destroyPersistentStoresOnErrorDuringLoad
    }
    
}
