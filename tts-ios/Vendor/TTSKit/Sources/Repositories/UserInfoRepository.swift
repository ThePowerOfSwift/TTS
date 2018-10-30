//
//  UserInfoRepository.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 07/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import CoreData
import RxSwift

public final class UserInfoRepository {
    
    private let connector: PersistentConnector
    public var logger: Logger?
    
    public init(connector: PersistentConnector, logger: Logger? = nil) {
        self.connector = connector
        self.logger = logger
    }
    
    public func observe(fetchRequest: NSFetchRequest<UserInfoEntity>) -> Observable<[UserInfo]> {
        return FetchedResultsObservable(fetchRequest: fetchRequest, managedObjectContext: connector.viewContext).asObservable().map({ result in
            let decoder = JSONDecoder()
            return result.compactMap {try? decoder.decode(UserInfo.self, from: $0.json!)}
        })
    }
    
    public func save(_ objects: [UserInfo], exclusively: Bool) -> Completable {
        return Completable.create { [connector, logger] subscribe -> Disposable in
            connector.performBackgroundTask { context in
                let entities: [UserInfoEntity]
                do {
                    let request: NSFetchRequest<UserInfoEntity> = UserInfoEntity.fetchRequest()
                    entities = try context.fetch(request)
                } catch {
                    logger?.error("%{public}@", String(describing: error))
                    subscribe(.error(error))
                    return
                }
                
                let encoder = JSONEncoder()
                
                for object in objects {
                    var entity: UserInfoEntity
                    if let first = entities.first(where: {object.phone.rawValue == $0.phone}) {
                        entity = first
                    } else {
                        entity = UserInfoEntity(context: context)
                    }
                    
                    entity.phone = object.phone.rawValue
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
