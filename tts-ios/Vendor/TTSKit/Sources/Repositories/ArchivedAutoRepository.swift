//
//  ArchivedAutoRepository.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 14/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import CoreData
import RxSwift

public final class ArchivedAutoRepository {
    
    private let connector: PersistentConnector
    public var logger: Logger?
    
    public init(connector: PersistentConnector, logger: Logger? = nil) {
        self.connector = connector
        self.logger = logger
    }
    
    public func observe(fetchRequest: NSFetchRequest<ArchivedAutoEntity>) -> Observable<[UserAuto]> {
        return FetchedResultsObservable(fetchRequest: fetchRequest, managedObjectContext: connector.viewContext).asObservable().map({ result in
            let decoder = JSONDecoder()
            return result.compactMap {try? decoder.decode(UserAuto.self, from: $0.json!)}
        })
    }
    
    public func save(_ objects: [UserAuto], exclusively: Bool) -> Completable {
        return Completable.create { [connector, logger] subscribe -> Disposable in
            connector.performBackgroundTask { context in
                let entities: [ArchivedAutoEntity]
                do {
                    let request: NSFetchRequest<ArchivedAutoEntity> = ArchivedAutoEntity.fetchRequest()
                    entities = try context.fetch(request)
                } catch {
                    logger?.error("%{public}@", String(describing: error))
                    subscribe(.error(error))
                    return
                }
                
                let encoder = JSONEncoder()
                
                for (index, object) in zip(0..<objects.count, objects) {
                    var entity: ArchivedAutoEntity
                    if let first = entities.first(where: {$0.id == object.id}) {
                        entity = first
                    } else {
                        entity = ArchivedAutoEntity(context: context)
                    }
                    
                    entity.id = object.id
                    entity.order = numericCast(index)
                    do {
                        entity.json = try encoder.encode(object)
                    } catch {
                        logger?.error("%{public}@", String(describing: error))
                        subscribe(.error(error))
                        return
                    }
                }
                
                if exclusively {
                    for entity in entities {
                        if !context.updatedObjects.contains(where: { $0.objectID == entity.objectID }) {
                            context.delete(entity)
                        }
                    }
                }
                
                do {
                    try context.saveIfHasChanges()
                    subscribe(.completed)
                } catch {
                    logger?.error("%{public}@", String(describing: error))
                    subscribe(.error(error))
                }
            }
            
            return Disposables.create()
        }
    }
    
}
