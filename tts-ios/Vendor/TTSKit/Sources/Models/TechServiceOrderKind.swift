//
//  TechServiceOrderKind.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 26/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import Foundation

public enum TechServiceOrderKind {
    
    case techService(tsUid: String, typeUid: String, otherWork: String?)
    
    case otherWork(String)
    
}
