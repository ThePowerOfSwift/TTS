//
//  ServiceCentersRepository.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 26/03/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import CoreData
import RxSwift
import CoreLocation

/// Inserts or updates service centers and deletes outdated entities
private func map(_ objects: [ServiceCenter], context: NSManagedObjectContext) throws -> [ServiceCenterEntity] {
    let request: NSFetchRequest<ServiceCenterEntity> = ServiceCenterEntity.fetchRequest()
    let entities = try context.fetch(request)
    
    let encoder = JSONEncoder()
    
    let result = try objects.reduce(into: [ServiceCenterEntity]()) { result, object in
        var entity: ServiceCenterEntity
        if let first = entities.first(where: {$0.id == object.id}) {
            entity = first
        } else {
            entity = ServiceCenterEntity(context: context)
        }
        
        entity.id = numericCast(object.id)
        entity.json = try encoder.encode(object)
        
        result.append(entity)
    }
    
    for entity in entities {
        if !context.updatedObjects.contains(where: { $0.objectID == entity.objectID }) {
            context.delete(entity)
        }
    }
    
    return result
}

public final class ServiceCentersRepository {
    
    private let connector: PersistentConnector
    public var logger: Logger?
    
    public init(connector: PersistentConnector, logger: Logger? = nil) {
        self.connector = connector
        self.logger = logger
    }
    
    public func observe(fetchRequest: NSFetchRequest<ServiceCenterGroupEntity>) -> Observable<[ServiceCenterGroup]> {
        return FetchedResultsObservable(fetchRequest: fetchRequest, managedObjectContext: connector.viewContext).asObservable().map({ result in
            return result.compactMap { try? ServiceCenterGroup(entity: $0) }
        })
    }
    
    public func save(_ objects: [ServiceCenterGroup]) -> Completable {
        return Completable.create { [connector, logger] subscribe -> Disposable in
            connector.performBackgroundTask { context in
                // fetch service center group entities
                let groups: [ServiceCenterGroupEntity]
                do {
                    let request: NSFetchRequest<ServiceCenterGroupEntity> = ServiceCenterGroupEntity.fetchRequest()
                    groups = try context.fetch(request)
                } catch {
                    logger?.error("%{public}@", String(describing: error))
                    subscribe(.error(error))
                    return
                }
                
                // convert ServiceCenter model to ServiceCenterEntity
                let services: [ServiceCenterEntity]
                do {
                    services = try map(objects.reduce(into: [ServiceCenter](), { $0.append(contentsOf: $1.services) }), context: context)
                } catch {
                    logger?.error("%{public}@", String(describing: error))
                    subscribe(.error(error))
                    return
                }
                
                // convert ServiceCenterGroup model to ServiceCenterGroupEntity
                for (index, object) in zip(0..<objects.count, objects) {
                    var entity: ServiceCenterGroupEntity
                    if let first = groups.first(where: {$0.order == index}) {
                        entity = first
                    } else {
                        entity = ServiceCenterGroupEntity(context: context)
                    }
                    
                    entity.address = object.address
                    entity.order = numericCast(index)
                    entity.longitude = object.coordinatesLongitude
                    entity.latitude = object.coordinatesLatitude
                    entity.services = NSOrderedSet(array: services.filter { entity in
                        object.services.contains(where: { entity.id == $0.id })
                    })
                }
                
                // delete outdated entities
                for entity in groups {
                    if !context.updatedObjects.contains(where: { $0.objectID == entity.objectID }) {
                        context.delete(entity)
                    }
                }
                
                // save changes
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

extension ServiceCenterGroup {
    
    fileprivate init(entity: ServiceCenterGroupEntity) throws {
        address = entity.address!
        coordinatesLongitude = entity.longitude!
        coordinatesLatitude = entity.latitude!
        services = try entity.services?.compactMap {
            guard let entity = $0 as? ServiceCenterEntity else { return nil }
            return try ServiceCenter.create(from: entity)
        } ?? []
    }
    
}

extension ServiceCenter {
    
    fileprivate static func create(from entity: ServiceCenterEntity) throws -> ServiceCenter {
        let decoder = JSONDecoder()
        return try decoder.decode(ServiceCenter.self, from: entity.json!)
    }
    
}
