//
//  AlamofireExecutor.swift
//  tts
//
//  Created by Dmitry Nesterenko on 13/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

extension SessionManager {
    
    public static let `default`: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Accept-Encoding": "gzip;q=1.0, compress;q=0.5"]
        configuration.httpAdditionalHeaders = ["Content-Type": "application/x-www-form-urlencoded"]

        return SessionManager(configuration: configuration)
    }()    
    
}

final class AlamofireExecutor: URLRequestExecuting {
    
    let manager: SessionManager
    
    var logger: Logger?
    
    var completionQueue: DispatchQueue?
    
    init(manager: SessionManager = SessionManager.default) {
        self.manager = manager
        self.completionQueue = DispatchQueue.global(qos: .default)
    }
    
    func execute(_ request: Foundation.URLRequest, completion: @escaping (HTTPURLResponse?, Data?, Error?) -> Void) -> Cancelable {
        var backgroundTask = UIBackgroundTaskIdentifier.invalid
        backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            UIApplication.shared.endBackgroundTask(backgroundTask)
        })
        
        let dataRequest = manager.request(request).response(queue: completionQueue) { result in
            UIApplication.shared.endBackgroundTask(backgroundTask)
            completion(result.response, result.data, result.error)
        }
        
        #if DEBUG
        logger?.debug("%@", String(reflecting: dataRequest))
        #endif
        
        return Disposables.create {
            dataRequest.cancel()
        }
    }
    
    func upload(_ source: UploadSource, request: Foundation.URLRequest, progress: ((Progress) -> Void)?, completion: @escaping (HTTPURLResponse?, Data?, Error?) -> Void) -> Cancelable {
        let upload: (UploadRequest) -> Void = { [weak self] request in
            request
                .uploadProgress {
                    progress?($0)
                }.response(queue: self?.completionQueue) { result in
                    completion(result.response, result.data, result.error)
                }
    
            #if DEBUG
            self?.logger?.debug("%@", String(reflecting: request))
            #endif
        }
        
        switch source {
        case .data(let data):
            let request = manager.upload(data, with: request)
            upload(request)
            return Disposables.create { request.cancel() }
            
        case .fileURL(let url):
            let request = manager.upload(url, with: request)
            upload(request)
            return Disposables.create { request.cancel() }
            
        case .stream(let stream):
            let request = manager.upload(stream, with: request)
            upload(request)
            return Disposables.create { request.cancel() }

        case .multipartFormData(let multipartFormData):
            var canceled = false
            var uploadRequest: UploadRequest?
            manager.upload(multipartFormData: multipartFormData, with: request, encodingCompletion: { result in
                guard !canceled else { return }
                
                switch result {
                case .success(let request, _, _):
                    uploadRequest = request
                    upload(request)
                case .failure(let error):
                    completion(nil, nil, error)
                }
            })
            
            return Disposables.create {
                canceled = true
                uploadRequest?.cancel()
            }
        }
    }
    
}
