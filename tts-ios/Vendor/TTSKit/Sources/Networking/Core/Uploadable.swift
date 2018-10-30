//
//  Uploadable.swift
//  tts
//
//  Created by Dmitry Nesterenko on 08/09/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import Alamofire

public enum UploadSource {
    
    case data(Data)
    
    case fileURL(URL)
    
    case stream(InputStream)
    
    case multipartFormData((MultipartFormData) -> Void)
    
}

public protocol Uploadable: NetworkRequest {

    func uploadSource() -> UploadSource
    
}
