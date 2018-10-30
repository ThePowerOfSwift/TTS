//
//  URLRequestExecuting.swift
//  tts
//
//  Created by Dmitry Nesterenko on 08/09/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import RxSwift

public protocol URLRequestExecuting {
    
    func execute(_ request: Foundation.URLRequest, completion: @escaping (HTTPURLResponse?, Data?, Error?) -> Void) -> Cancelable
    
    func upload(_ source: UploadSource, request: Foundation.URLRequest, progress: ((Progress) -> Void)?, completion: @escaping (HTTPURLResponse?, Data?, Error?) -> Void) -> Cancelable
    
}
