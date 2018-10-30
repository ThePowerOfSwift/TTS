//
//  ServiceCentersService.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 26/03/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation
import RxSwift
import CoreData
import CoreLocation

public final class ServiceCentersService {
    
    private let repository: ServiceCentersRepository
    private let client: URLRequestManaging
    
    public init(client: URLRequestManaging, repository: ServiceCentersRepository) {
        self.client = client
        self.repository = repository
    }
    
    public func pull() -> Single<[ServiceCenterGroup]> {
        return client.execute(GetServiceCenterGroupRequest())
            .map {$0.value.services}
            .flatMap { [repository] in repository.save($0).andThen(Single.just($0)) }
    }
    
    public func observeAllSortedByOrder(ascending: Bool = true) -> Observable<[ServiceCenterGroup]> {
        let fetchRequest: NSFetchRequest<ServiceCenterGroupEntity> = ServiceCenterGroupEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: ascending)]
        fetchRequest.relationshipKeyPathsForPrefetching = ["services"]
        return repository.observe(fetchRequest: fetchRequest)
    }
    
    public func observe(latitude: String, longitude: String) -> Observable<ServiceCenterGroup?> {
        let fetchRequest: NSFetchRequest<ServiceCenterGroupEntity> = ServiceCenterGroupEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "latitude = %@ AND longitude = %@", latitude, longitude)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        fetchRequest.fetchLimit = 1
        fetchRequest.relationshipKeyPathsForPrefetching = ["services"]
        return repository.observe(fetchRequest: fetchRequest).map {$0.first}
    }
    
    public func observe(serviceId: Int) -> Observable<ServiceCenterGroup?> {
        let fetchRequest: NSFetchRequest<ServiceCenterGroupEntity> = ServiceCenterGroupEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "ANY services.id == %d", serviceId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        fetchRequest.fetchLimit = 1
        fetchRequest.relationshipKeyPathsForPrefetching = ["services"]
        return repository.observe(fetchRequest: fetchRequest).map {$0.first}
    }
    
}
