//
//  TreatmentRepository.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 18/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

public final class TreatmentRepository {
    
    private let connector: PersistentConnector
    public var logger: Logger?
    
    public init(connector: PersistentConnector, logger: Logger? = nil) {
        self.connector = connector
        self.logger = logger
    }
    
    public func observe(fetchRequest: NSFetchRequest<TreatmentEntity>) -> Observable<[String: [Treatment]]> {
        return FetchedResultsObservable(fetchRequest: fetchRequest, managedObjectContext: connector.viewContext).asObservable().map({ result in
            let decoder = JSONDecoder()
            return result.reduce(into: [String: [Treatment]](), {
                if let id = $1.auto_id, let model = try? decoder.decode(Treatment.self, from: $1.json!) {
                    $0[id] = $0[id, default: []] + [model]
                }
            })
        })
    }
    
    public func save(_ objects: [String: [Treatment]], exclusively: Bool) -> Completable {
        return Completable.create { [connector, logger] subscribe -> Disposable in
            connector.performBackgroundTask { context in
                let entities: [TreatmentEntity]
                do {
                    let request: NSFetchRequest<TreatmentEntity> = TreatmentEntity.fetchRequest()
                    entities = try context.fetch(request)
                } catch {
                    logger?.error("%{public}@", String(describing: error))
                    subscribe(.error(error))
                    return
                }
                
                let encoder = JSONEncoder()
                
                for (id, objects) in objects {
                    for object in objects {
                        var entity: TreatmentEntity
                        if let first = entities.first(where: {$0.id == object.id}) {
                            entity = first
                        } else {
                            entity = TreatmentEntity(context: context)
                        }
                    
                        entity.id = object.id
                        entity.date = object.date
                        entity.auto_id = id
                        do {
                            entity.json = try encoder.encode(object)
                        } catch {
                            logger?.error("%{public}@", String(describing: error))
                            subscribe(.error(error))
                            return
                        }
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
