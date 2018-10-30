//
//  TreatmentService.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 18/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

public final class TreatmentService {
    
    private let client: URLRequestManaging
    private let repository: TreatmentRepository
    
    public init(client: URLRequestManaging, repository: TreatmentRepository) {
        self.client = client
        self.repository = repository
    }
    
    public func pull() -> Single<[String: [Treatment]]> {
        return client.execute(GetTreatmentsListRequest())
            .map { response in response.value.treatments }
            .flatMap { [repository] in repository.save($0, exclusively: true).andThen(Single.just($0)) }
    }
    
    public func observeAllSortedByOrder(autoId: String, ascending: Bool) -> Observable<[Treatment]> {
        let fetchRequest: NSFetchRequest<TreatmentEntity> = TreatmentEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "auto_id = %@", autoId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: ascending)]
        return repository.observe(fetchRequest: fetchRequest)
            .map { $0.first?.value }
            .filter { $0 != nil }
            .map { $0! }
    }
    
}
