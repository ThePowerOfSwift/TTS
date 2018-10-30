//
//  ImageDownloader+Extension.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 03/05/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire
import RxSwift

extension ImageDownloader {
    
    @discardableResult
    public func download(urls: [URL], success: @escaping ([URL: UIImage]) -> Void, failure: @escaping (Error) -> Void) -> [RequestReceipt] {
        var accumulator = [URL: UIImage]()
        var error: Error?
        var numberOfRequestsLeftToComplete = urls.count
        let urlRequests = urls.map {Foundation.URLRequest(url: $0)}
        
        return download(urlRequests) { response in
            if let url = response.request?.url, let image = response.result.value {
                accumulator[url] = image
            }
            
            if response.error != nil {
                error = response.error
            }
            
            numberOfRequestsLeftToComplete -= 1
            
            if numberOfRequestsLeftToComplete == 0 {
                if let error = error {
                    failure(error)
                } else {
                    success(accumulator)
                }
            }
        }
    }
    
    public func download(urls: [URL]) -> Single<[URL: UIImage]> {
        return Single.create(subscribe: { subscription -> Disposable in
            let requests = self.download(urls: urls, success: {
                subscription(.success($0))
            }, failure: {
                subscription(.error($0))
            })
            
            return Disposables.create {
                requests.forEach {
                    $0.request.cancel()
                }
            }
        })
    }
    
}
