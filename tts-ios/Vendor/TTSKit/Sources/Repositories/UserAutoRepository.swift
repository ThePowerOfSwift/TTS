//
//  UserAutoRepository.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 02/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import CoreData
import RxSwift

private func map(_ entities: [UserAutoEntity]) -> [UserAuto] {
    let decoder = JSONDecoder()
    return entities.compactMap {try? decoder.decode(UserAuto.self, from: $0.json!)}
}

public final class UserAutoRepository {

    private let connector: PersistentConnector
    public var logger: Logger?
    
    public init(connector: PersistentConnector, logger: Logger? = nil) {
        self.connector = connector
        self.logger = logger
    }
    
    public func observe(fetchRequest: NSFetchRequest<UserAutoEntity>) -> Observable<[UserAuto]> {
        return FetchedResultsObservable(fetchRequest: fetchRequest, managedObjectContext: connector.viewContext).asObservable().map(map)
    }
    
    public func fetch(_ fetchRequest: NSFetchRequest<UserAutoEntity>) throws -> [UserAuto] {
        let entities = try connector.viewContext.fetch(fetchRequest)
        return map(entities)
    }
    
    public func save(_ objects: [UserAuto], exclusively: Bool) -> Completable {
        return Completable.create { [connector, logger] subscribe -> Disposable in
            connector.performBackgroundTask { context in
                let entities: [UserAutoEntity]
                do {
                    let request: NSFetchRequest<UserAutoEntity> = UserAutoEntity.fetchRequest()
                    entities = try context.fetch(request)
                } catch {
                    logger?.error("%{public}@", String(describing: error))
                    subscribe(.error(error))
                    return
                }
                
                let encoder = JSONEncoder()
                
                for (index, object) in zip(0..<objects.count, objects) {
                    var entity: UserAutoEntity
                    if let first = entities.first(where: {$0.id == object.id}) {
                        entity = first
                    } else {
                        entity = UserAutoEntity(context: context)
                    }
                    
                    entity.id = object.id
                    entity.brandId = object.brandId as NSNumber?
                    entity.serviceId = object.serviceCenter?.id as NSNumber?
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
