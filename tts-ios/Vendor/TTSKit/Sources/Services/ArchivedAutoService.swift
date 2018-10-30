//
//  ArchivedAutoService.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 13/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

public final class ArchivedAutoService {
    
    private let client: URLRequestManaging
    private let repository: ArchivedAutoRepository
    
    public init(client: URLRequestManaging, repository: ArchivedAutoRepository) {
        self.client = client
        self.repository = repository
    }
    
    public func pull() -> Single<[UserAuto]> {
        return client.execute(GetUserAutoArchiveRequest())
            .map {$0.value.auto}
            .flatMap { [repository] in repository.save($0, exclusively: true).andThen(Single.just($0)) }
    }

    public func observeAllSortedByOrder() -> Observable<[UserAuto]> {
        let fetchRequest: NSFetchRequest<ArchivedAutoEntity> = ArchivedAutoEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        return repository.observe(fetchRequest: fetchRequest)
    }
    
    public func observe(id: String) -> Observable<UserAuto?> {
        let fetchRequest: NSFetchRequest<ArchivedAutoEntity> = ArchivedAutoEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.fetchLimit = 1
        return repository.observe(fetchRequest: fetchRequest).map {$0.first}
    }
    
    public func moveToArchive(vin: String) -> Completable {
        return client.execute(MoveToArchiveRequest(vin: vin))
            .flatMap { _ in self.pull() }
            .asCompletable()
    }
    
    public func removeFromArchive(vin: String) -> Completable {
        return client.execute(RemoveFromArchiveRequest(vin: vin))
            .flatMap { _ in self.pull() }
            .asCompletable()
    }
    
}
