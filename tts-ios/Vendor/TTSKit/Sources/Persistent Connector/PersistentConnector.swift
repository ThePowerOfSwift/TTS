//
//  PersistentConnector.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 23/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

private extension NSPersistentContainer {
    
    convenience init(url: URL) {
        let model = NSManagedObjectModel(contentsOf: url)!
        self.init(name: url.lastPathComponent, managedObjectModel: model)
    }
    
}

public final class PersistentConnector {
    
    private let url: URL
    private var pcontainer: NSPersistentContainer
    private let configuration: PersistentConnectorConfiguration
    
    public var viewContext: NSManagedObjectContext {
        return pcontainer.viewContext
    }
    
    private var backgroundContext: NSManagedObjectContext?
    
    public init?(url: URL, configuration: PersistentConnectorConfiguration = PersistentConnectorConfiguration()) {
        self.url = url
        self.configuration = configuration
        pcontainer = NSPersistentContainer(url: url)
    }
    
    public func connect() -> Completable {
        return Completable.create { [configuration] subscription -> Disposable in
            self.loadPersistentStores(completion: { [weak self] in
                let completed = {
                    if configuration.automaticallyMergesChangesFromParentToViewContext {
                        self?.pcontainer.viewContext.automaticallyMergesChangesFromParent = configuration.automaticallyMergesChangesFromParentToViewContext
                    }
                    subscription(.completed)
                }
                
                if let error = $0 {
                    if configuration.destroyPersistentStoresOnErrorDuringLoad {
                        self?.destroy(completion: {
                            if let error = $0 {
                                subscription(.error(error))
                                return
                            } else {
                                self?.loadPersistentStores(completion: {
                                    if let error = $0 {
                                        subscription(.error(error))
                                    } else {
                                        completed()
                                    }
                                })
                            }
                        })
                    } else {
                        subscription(.error(error))
                    }
                } else {
                    completed()
                }
            })
            
            return Disposables.create()
        }
    }
    
    private func loadPersistentStores(completion: @escaping (Error?) -> Void) {
        assert(pcontainer.persistentStoreCoordinator.persistentStores.count == 0, "Persistent stores has been already loaded before.")
        
        var numberOfPersistentStoresLeftToLoad = pcontainer.persistentStoreDescriptions.count
        var errors = [Error]()
        pcontainer.loadPersistentStores { _, error in
            numberOfPersistentStoresLeftToLoad -= 1
            
            if let error = error {
                errors.append(error)
            }
            
            if numberOfPersistentStoresLeftToLoad == 0 {
                completion(errors.first)
            }
        }
    }
    
    private var backgroundLock = Lock()
    public func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        backgroundLock.lock()
        if backgroundContext == nil {
             backgroundContext = pcontainer.newBackgroundContext()
        }
        backgroundLock.unlock()
        
        let context = backgroundContext!
        context.perform {
            block(context)
        }
    }
    
    private func destroy(completion: ((Error?) -> Void)?) {
        pcontainer.viewContext.performAndWait { self.pcontainer.viewContext.reset() }
        
        // destroy persistent store
        let coordinator = pcontainer.persistentStoreCoordinator
        coordinator.performAndWait {
            for description in pcontainer.persistentStoreDescriptions {
                if let url = description.url {
                    do {
                        try coordinator.destroyPersistentStore(at: url, ofType: description.type, options: description.options)
                    } catch {
                        completion?(error)
                        return
                    }
                }
            }
            
            // create new container and reset background context
            self.pcontainer = NSPersistentContainer(url: self.url)
            self.backgroundLock.lock()
            self.backgroundContext = nil
            self.backgroundLock.unlock()
            completion?(nil)
        }
    }
    
    public func destroy() -> Completable {
        return Completable.create { subscription -> Disposable in
            self.destroy(completion: {
                if let error = $0 {
                    subscription(.error(error))
                } else {
                    subscription(.completed)
                }
            })
            
            return Disposables.create()
        }
    }
    
}
