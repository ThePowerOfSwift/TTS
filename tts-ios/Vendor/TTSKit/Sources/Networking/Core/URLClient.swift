//
//  URLClient.swift
//  tts
//
//  Created by Dmitry Nesterenko on 08/09/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import RxSwift

/// Base object which acts as a manager for URLRequest
///
/// It's responsibility is to send requests, handle response, return mappend object and apply certain behaviors.
/// It is recommended to make a subclass with configured base url, executor or behaviors.
public final class URLClient: URLRequestManaging {
    
    public let baseURL: URL
    
    let executor: URLRequestExecuting
    
    public init(baseURL: URL, executor: URLRequestExecuting) {
        self.baseURL = baseURL
        self.executor = executor
    }
    
    // MARK: - Executing
    
    public func execute<Request: NetworkRequest>(_ request: Request) -> Single<Request.ResponseObject> {
        return Single.create { subscribe -> Disposable in
            let executor: (Foundation.URLRequest, @escaping (HTTPURLResponse?, Data?, Error?) -> Void) -> Cancelable = { request, completion in
                return self.executor.execute(request, completion: completion)
            }
            
            return self.execute(request, executor) { result in
                switch result {
                case .success(let response):
                    subscribe(.success(response))
                case .failure(let error):
                    subscribe(.error(error))
                }
            }
        }
    }
    
    private func execute<Request: NetworkRequest>(_ request: Request, _ executor: (Foundation.URLRequest, @escaping (HTTPURLResponse?, Data?, Error?) -> Void) -> Cancelable, completion: ((Result<Request.ResponseObject>) -> Void)?) -> Disposable {
        var urlRequest: Foundation.URLRequest
        do {
            urlRequest = try request.request(with: baseURL)
        } catch {
            if let completion = completion {
                let result = Result<Request.ResponseObject>(error: error)
                completion(result)
            }
            return Disposables.create()
        }
        
        // execute
        let cancelable = executor(urlRequest) { response, data, error in
            if let error = error {
                // complete
                if let completion = completion {
                    let result = Result<Request.ResponseObject>(error: error)
                    completion(result)
                }
            }
            
            do {
                // validate
                try request.validate(response, data: data, error: error)
                
                // map
                let object: Request.ResponseObject = try request.object(for: response, data: data)
                
                // complete
                if let completion = completion {
                    let result = Result<Request.ResponseObject>(value: object)
                    completion(result)
                }
            } catch {
                if let completion = completion {
                    let result = Result<Request.ResponseObject>(error: error)
                    completion(result)
                }
            }
        }
        
        return cancelable
    }
    
    public func upload<Request: Uploadable>(_ request: Request, progress: ((Progress) -> Void)?) -> Single<Request.ResponseObject> {
        return Single.create { subscribe -> Disposable in
            let executor: (Foundation.URLRequest, @escaping (HTTPURLResponse?, Data?, Error?) -> Void) -> Cancelable = { urlRequest, completion in
                return self.executor.upload(request.uploadSource(), request: urlRequest, progress: progress, completion: completion)
            }
            
            return self.execute(request, executor) { result in
                switch result {
                case .success(let response):
                    subscribe(.success(response))
                case .failure(let error):
                    subscribe(.error(error))
                }
            }
        }
    }
    
}
