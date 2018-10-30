//
//  AuthService.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 25/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import RxSwift

public final class AuthService {
    
    private let client: URLRequestManaging
    private let sessionStorage: SessionStorage
    private let connector: PersistentConnector
    
    public init(client: URLRequestManaging, sessionStorage: SessionStorage, connector: PersistentConnector) {
        self.client = client
        self.sessionStorage = sessionStorage
        self.connector = connector
    }
    
    public func getTempToken(phone: PhoneNumber) -> Single<GetTempTokenResponse> {
        let request = GetTempTokenRequest(phone: phone)
        return client.execute(request).map {$0.value}
    }
    
    /// Requests access token and saves it to the session storage
    public func getAccessToken(phone: PhoneNumber, tempToken: String, smsCode: String) -> Single<GetAccessTokenResponse> {
        let request = GetAccessTokenRequest(phone: phone, temp_token: tempToken, sms_code: smsCode)
        return client.execute(request)
            .map {$0.value}
            .do(onSuccess: { [sessionStorage] in
                let credential = SessionCredential(accessToken: $0.access_token, extensionToken: $0.extension_token)
                try sessionStorage.save(credential)
            })
    }
    
    public func logout() -> Completable {
        // unregister device from remote notifications
        UIApplication.shared.unregisterForRemoteNotifications()
        
        // send logout request which internally unregisters firebase token from notifications
        // set short timeout interval because we don't interested in actual response
        // and ignore request errors if any
        let logout = client.execute(LogoutRequest(timeoutInterval: 1))
            .map { $0.value }
            .catchErrorJustReturn(VoidResponse())
        
        // cleanup local data storage
        let cleanup = connector
            .destroy()
            .andThen(connector.connect())
        
        return logout.asCompletable().andThen(cleanup)
            .do(onCompleted: { try self.sessionStorage.save(nil) })
    }
    
}
