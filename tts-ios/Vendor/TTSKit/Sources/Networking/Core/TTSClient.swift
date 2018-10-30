//
//  TTSClient.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 25/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

/// Concrete implementation for tts api client
///
/// It is used by the application to send requests and handle session expiration and request validation.
public final class TTSClient: URLRequestManaging {
    
    public let baseURL: URL
    
    /// This handler is called when request finished with error code 22, 26, and when the extension token request failed.
    ///
    /// This handler can be called multiple times for each failed request.
    /// Take into account that it's called on a background thread, so make sure to dispatch it to main queue if needed.
    public var invalidAccessTokenHandler: ((_ completion: @escaping () -> Void) -> Void)?
    private let executor: AlamofireExecutor
    private let client: URLClient
    private let sessionStorage: SessionStorage
    
    public var logger: Logger? {
        get {
            return executor.logger
        }
        set {
            executor.logger = newValue
        }
    }
    
    public init(sessionStorage: SessionStorage) {
        self.baseURL = URL(string: "https://my.tts.ru/api/v2")!
        self.sessionStorage = sessionStorage
        
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpShouldSetCookies = false
        sessionConfiguration.urlCache = nil

        executor = AlamofireExecutor(manager: SessionManager(configuration: sessionConfiguration))
        client = URLClient(baseURL: baseURL, executor: executor)
        
        logger = Logger(subsystem: "tts", category: "api")
    }
    
    private func applyAccessTokenIdentifierIfNeeded<Request: NetworkRequest>(_ request: inout Request) {
        if var accessTokenIdentifiable = request as? AccessTokenIdentifiable {
            extendTokenRequestLock.lock()
            accessTokenIdentifiable.accessToken = try? sessionStorage.credential().accessToken
            extendTokenRequestLock.unlock()
            if let mutatedRequest = accessTokenIdentifiable as? Request {
                request = mutatedRequest
            }
        }
    }
    
    public func execute<Request: NetworkRequest>(_ request: Request) -> Single<Request.ResponseObject> {
        return execute(request, handleTokenExpiration: true)
    }
    
    private func execute<Request: NetworkRequest>(_ request: Request, handleTokenExpiration: Bool) -> Single<Request.ResponseObject> {
        var request = request
        applyAccessTokenIdentifierIfNeeded(&request)
        
        return client.execute(request).catchError { [weak self] error -> Single<Request.ResponseObject> in
            // try to extend token when got "AccessToken expired" error
            guard
                let self = self,
                case ResponseMapperError.mappingFailed(let underlying) = error,
                case ResponseResultError.invalidErrorCode(let code, _) = underlying else {
                    throw error
            }
            
            switch code {
            case 1, 8: // access denied
                if handleTokenExpiration {
                    // There is no need to send token extension request when the `sendSharedExtendTokenRequest`
                    // was completed earlier but the request was just finished with error.
                    self.extendTokenRequestLock.lock()
                    let currentAccessToken = try self.sessionStorage.credential().accessToken
                    let requestAccessToken = (request as? AccessTokenIdentifiable)?.accessToken
                    self.extendTokenRequestLock.unlock()
                    if requestAccessToken != currentAccessToken {
                        return self.execute(request, handleTokenExpiration: false)
                    }

                    // We try to extend access token when got 1 and 8 error codes.
                    // But there is a chance when the token extend request will complete by all subsequent requests will still return the same 1 or 8 codes.
                    // In that case we should automatically deauthorize user by calling `triggerInvalidAccessTokenHandler` method
                    // see https://redmine.e-legion.com/issues/116691
                    return self.sendSharedExtendTokenRequest()
                        .flatMap { _ in self.execute(request, handleTokenExpiration: false) }
                } else {
                    return self.triggerInvalidAccessTokenHandler()
                        .andThen(Single.error(error))
                }
            case 22, 26:
                return self.triggerInvalidAccessTokenHandler()
                    .andThen(Single.error(error))
            default:
                throw error
            }
        }
    }
    
    public func upload<Request>(_ request: Request, progress: ((Progress) -> Void)?) -> PrimitiveSequence<SingleTrait, Request.ResponseObject> where Request: Uploadable {
        return client.upload(request, progress: progress)
    }
    
    private var extensionTokenRequestObservable: Single<ResponseResult<ExtensionTokenResponse>>?
    private let extendTokenRequestLock = Lock()
    
    private func sendSharedExtendTokenRequest() -> Single<ResponseResult<ExtensionTokenResponse>> {
        extendTokenRequestLock.lock()
        defer { extendTokenRequestLock.unlock() }
        
        if let observable = extensionTokenRequestObservable {
            return observable
        } else {
            let credential: SessionCredential
            do {
                credential = try sessionStorage.credential()
            } catch {
                return Single.error(error)
            }
            
            var request = ExtensionTokenRequest(extensionToken: credential.extensionToken)
            request.accessToken = credential.accessToken
            let observable = client.execute(request)
                .do(onSuccess: { [weak self] in
                    self?.extendTokenRequestLock.lock()
                    let credential = SessionCredential(accessToken: $0.value.access_token, extensionToken: $0.value.extension_token)
                    try self?.sessionStorage.save(credential)
                    self?.extendTokenRequestLock.unlock()
                }, onDispose: { [weak self] in
                    self?.extendTokenRequestLock.lock()
                    self?.extensionTokenRequestObservable = nil
                    self?.extendTokenRequestLock.unlock()
                })
                .catchError({ [weak self] error -> Single<ResponseResult<ExtensionTokenResponse>> in
                    // There is a chance when the token extend request will fail
                    // In that case we should automatically deauthorize user by calling `triggerInvalidAccessTokenHandler` method
                    // see https://redmine.e-legion.com/issues/116691
                    guard let self = self else { throw error }
                    return self.triggerInvalidAccessTokenHandler()
                        .andThen(Single.error(error))
                })
                .asObservable()
                .share(replay: 1)
                .asSingle()
            extensionTokenRequestObservable = observable
            return observable
        }
    }
    
    private func triggerInvalidAccessTokenHandler() -> Completable {
        guard let invalidAccessTokenHandler = self.invalidAccessTokenHandler else { return Completable.empty() }
        
        return Completable.create(subscribe: { subscription -> Disposable in
            invalidAccessTokenHandler {
                subscription(.completed)
            }
            return Disposables.create()
        })
    }
    
}
