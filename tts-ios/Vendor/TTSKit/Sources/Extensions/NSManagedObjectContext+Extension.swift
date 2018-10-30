//
//  NSManagedObjectContext+Extension.swift
//  tts
//
//  Created by Dmitry Nesterenko on 14/06/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    
    /// - Important: Always verify that the context has uncommitted changes (using the hasChanges property) before invoking the save: method. Otherwise, Core Data may perform unnecessary work.
    public func saveIfHasChanges() throws {
        if hasChanges {
            try save()
        }
    }
    
}
