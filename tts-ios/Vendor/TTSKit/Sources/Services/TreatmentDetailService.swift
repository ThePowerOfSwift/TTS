//
//  TreatmentDetailService.swift
//  Tests
//
//  Created by Dmitry Nesterenko on 20/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

public final class TreatmentDetailService {
    
    private let client: URLRequestManaging
    private let repository: TreatmentDetailRepository
    
    public init(client: URLRequestManaging, repository: TreatmentDetailRepository) {
        self.client = client
        self.repository = repository
    }
    
    public func pull(treatmentId: String) -> Single<GetTreatmentDetailResponse?> {
        return client.execute(GetTreatmentDetailRequest(treatmentId: treatmentId))
            .map { $0.value }
            .flatMap { [repository] in
                if $0.treatment == nil {
                    return repository.delete(treatmentId).andThen(Single.just($0))
                } else {
                    return repository.save([treatmentId: $0], exclusively: false).andThen(Single.just($0))
                }
            }
    }
    
    public func observe(treatmentId: String) -> Observable<GetTreatmentDetailResponse?> {
        let fetchRequest: NSFetchRequest<TreatmentDetailEntity> = TreatmentDetailEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "treatment_id = %@", treatmentId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "treatment_id", ascending: true)]
        return repository.observe(fetchRequest: fetchRequest)
            .map { $0.first?.value }
    }
    
}
