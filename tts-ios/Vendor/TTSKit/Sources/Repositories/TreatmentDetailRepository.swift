//
//  TreatmentDetailRepository.swift
//  Tests
//
//  Created by Dmitry Nesterenko on 20/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

public final class TreatmentDetailRepository {
    
    private let connector: PersistentConnector
    public var logger: Logger?
    
    public init(connector: PersistentConnector, logger: Logger? = nil) {
        self.connector = connector
        self.logger = logger
    }
    
    public func observe(fetchRequest: NSFetchRequest<TreatmentDetailEntity>) -> Observable<[String: GetTreatmentDetailResponse]> {
        return FetchedResultsObservable(fetchRequest: fetchRequest, managedObjectContext: connector.viewContext).asObservable().map({ result in
            let decoder = JSONDecoder()
            return result.reduce(into: [String: GetTreatmentDetailResponse](), {
                if let id = $1.treatment_id, let model = try? decoder.decode(GetTreatmentDetailResponse.self, from: $1.json!) {
                    $0[id] = model
                }
            })
        })
    }
    
    public func save(_ objects: [String: GetTreatmentDetailResponse], exclusively: Bool) -> Completable {
        return Completable.create { [connector, logger] subscribe -> Disposable in
            connector.performBackgroundTask { context in
                let entities: [TreatmentDetailEntity]
                do {
                    let request: NSFetchRequest<TreatmentDetailEntity> = TreatmentDetailEntity.fetchRequest()
                    entities = try context.fetch(request)
                } catch {
                    logger?.error("%{public}@", String(describing: error))
                    subscribe(.error(error))
                    return
                }
                
                let encoder = JSONEncoder()
                
                for (id, object) in objects {
                    var entity: TreatmentDetailEntity
                    if let first = entities.first(where: {$0.treatment_id == object.treatment?.id}) {
                        entity = first
                    } else {
                        entity = TreatmentDetailEntity(context: context)
                    }
                        
                    entity.treatment_id = id
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
    
    public func delete(_ treatmentId: String) -> Completable {
        return Completable.create { [connector, logger] subscribe -> Disposable in
            connector.performBackgroundTask { context in
                do {
                    let request: NSFetchRequest<TreatmentDetailEntity> = TreatmentDetailEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "treatment_id = %@", treatmentId)
                    request.fetchLimit = 1
                    let entities = try context.fetch(request)
                    entities.forEach { context.delete($0) }
                } catch {
                    logger?.error("%{public}@", String(describing: error))
                    subscribe(.error(error))
                    return
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
