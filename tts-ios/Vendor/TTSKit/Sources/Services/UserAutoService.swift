//
//  UserAutoService.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 02/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

public final class UserAutoService {
    
    private let repository: UserAutoRepository
    private let client: URLRequestManaging
    
    public init(client: URLRequestManaging, repository: UserAutoRepository) {
        self.client = client
        self.repository = repository
    }
    
    public func pull() -> Single<[UserAuto]> {
        return client.execute(GetUserAutoRequest())
            .map {$0.value.auto}
            .flatMap { [repository] in repository.save($0, exclusively: true).andThen(Single.just($0)) }
    }
    
    public func fetchAll(brandId: Int?) -> [UserAuto] {
        let fetchRequest: NSFetchRequest<UserAutoEntity> = UserAutoEntity.fetchRequest()
        if let brandId = brandId {
            fetchRequest.predicate = NSPredicate(format: "brandId == %d", brandId)
        }
        return try! repository.fetch(fetchRequest) // swiftlint:disable:this force_try
    }
    
    public func observeAllSortedByOrder(ascending: Bool = true) -> Observable<[UserAuto]> {
        return observe(ascending: ascending, configure: nil)
    }
    
    public func observe(id: String, ascending: Bool = true) -> Observable<UserAuto?> {
        return observe(ascending: ascending, configure: {
            $0.predicate = NSPredicate(format: "id == %@", id)
            $0.fetchLimit = 1
        }).map {$0.first}
    }
    
    public func observe(serviceId: Int) -> Observable<[UserAuto]> {
        return observe(ascending: true, configure: {
            $0.predicate = NSPredicate(format: "serviceId == %d", serviceId)
        })
    }
    
    private func observe(ascending: Bool, configure: ((inout NSFetchRequest<UserAutoEntity>) -> Void)?) -> Observable<[UserAuto]> {
        var fetchRequest: NSFetchRequest<UserAutoEntity> = UserAutoEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: ascending)]
        configure?(&fetchRequest)
        return repository.observe(fetchRequest: fetchRequest)
    }
    
    public func addUserAuto(brandId: Int, modelId: Int, complectationId: Int?, year: Int, gosnomer: String, vin: String, mileage: Int?, serviceId: String?) -> Single<VoidResponse> {
        return client.execute(AddUserAutoRequest(brandId: brandId, modelId: modelId, completationId: complectationId, year: year, gosnomer: gosnomer, vin: vin, mileage: mileage, serviceId: serviceId))
            .map { $0.value }
    }
    
    public func bindingServiceCenter(uid: String, vin: String) -> Single<VoidResponse> {
        let request = BindingServiceCenterRequest(uid: uid, vin: vin)
        return client.execute(request).map {$0.value}
    }
    
}
