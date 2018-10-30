//
//  UserInfoService.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 07/02/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation
import RxSwift
import CoreData

public final class UserInfoService {
    
    private let client: URLRequestManaging
    private let repository: UserInfoRepository
    
    public init(client: URLRequestManaging, repository: UserInfoRepository) {
        self.client = client
        self.repository = repository
    }
    
    public func addUserNameRequest(firstName: String, lastName: String) -> Single<VoidResponse> {
        let request = AddUserNameRequest(firstName: firstName, lastName: lastName)
        return client.execute(request).map {$0.value}
    }

    public func pull() -> Single<UserInfo> {
        return client.execute(GetUserInfoRequest())
            .map {$0.value}
            .flatMap { [repository] in repository.save([$0], exclusively: true).andThen(Single.just($0)) }
    }
    
    public func observe() -> Observable<[UserInfo]> {
        let fetchRequest: NSFetchRequest<UserInfoEntity> = UserInfoEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "phone", ascending: true)]
        return repository.observe(fetchRequest: fetchRequest)
    }
    
    public func setPushNotify(enabled: Bool) -> Single<UserInfo> {
        let pushStatus = enabled ? PushStatus.enabled : PushStatus.disabled
        let request = SetPushNotifyRequest(pushStatus: pushStatus)
        return client.execute(request)
            .flatMap { _ in self.pull() }
    }
    
    public func setPushToken(token: String) -> Single<VoidResponse> {
        let request = SetPushTokenRequest(token: token)
        return client.execute(request).map { $0.value }
    }
    
    public func callback() -> Single<VoidResponse> {
        let request = CallbackRequest()
        return client.execute(request).map {$0.value}
    }
    
}
