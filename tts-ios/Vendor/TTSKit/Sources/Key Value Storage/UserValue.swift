//
//  UserValue.swift
//  TTSKit
//
//  Created by Dmitry Nesterenko on 25/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

public protocol UserValue {
    
    associatedtype T: Codable
    
    static var key: String { get }
    
    func set(_ value: T)
    
    func get() -> T
    
}

extension UserValue {
    
    public static var key: String {
        let prefix = Bundle.main.bundleIdentifier
        let suffix = String(describing: self).lcfirst().replacing(charactersIn: .whitespaces, with: "_").dropSuffix("UserValue")
        
        let result: String
        if let prefix = prefix {
            result = "\(prefix).\(suffix)"
        } else {
            result = String(suffix)
        }
        return result.replacingOccurrences(of: ".", with: "_")
    }
    
    public var value: T {
        get {
            return get()
        }
        set {
            set(newValue)
        }
    }
    
}
