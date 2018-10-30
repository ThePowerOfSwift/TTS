//
//  AccessTokenIdentifiable.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 29/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

protocol AccessTokenIdentifiable {
    
    var accessToken: String? { get set }
    
}

extension AccessTokenIdentifiable {
    
    var accessTokenHeader: [String: String]? {
        guard let accessToken = accessToken else { return nil }
        return ["AccessToken": accessToken]
    }
    
}
