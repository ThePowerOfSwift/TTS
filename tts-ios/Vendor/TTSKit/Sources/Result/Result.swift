//
//  Result.swift
//  tts
//
//  Created by Dmitry Nesterenko on 20/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation

/// - See [CwlResult.swift](https://github.com/mattgallagher/CwlUtils/blob/master/Sources/CwlUtils/CwlResult.swift)
public enum Result<T> {
 
    /// Success wraps a T value
    case success(T)
    
    /// Failure wraps an Error
    case failure(Error)

    /// Construct a result from a `throws` function
    public init(_ capturing: () throws -> T) {
        do {
            self = .success(try capturing())
        } catch {
            self = .failure(error)
        }
    }
    
    /// Initializes a Result from an optional success value
    /// and an optional error. Useful for converting return
    /// values from many asynchronous Apple APIs to Result.
    public init(value: T?, error: Error?) {
        if let value = value {
            self = .success(value)
        } else {
            self = .failure(error!)
        }
    }

    public init(value: T) {
        self.init(value: value, error: nil)
    }
    
    public init(error: Error) {
        self.init(value: nil, error: error)
    }
    
    public var value: T? {
        switch self {
        case .success(let value): return value
        case .failure: return nil
        }
    }

    public var error: Error? {
        switch self {
        case .success: return nil
        case .failure(let error): return error
        }
    }
    
    /// Chains another Result to this one. In the event that this Result is a .Success, the provided transformer closure is used to generate another Result (wrapping a potentially new type). In the event that this Result is a .Failure, the next Result will have the same error as this one.
    public func flatMap<U>(_ transform: (T) -> Result<U>) -> Result<U> {
        switch self {
        case .success(let val): return transform(val)
        case .failure(let e): return .failure(e)
        }
    }
    
    /// Chains another Result to this one. In the event that this Result is a .Success, the provided transformer closure is used to transform the value into another value (of a potentially new type) and a new Result is made from that value. In the event that this Result is a .Failure, the next Result will have the same error as this one.
    public func map<U>(_ transform: (T) throws -> U) -> Result<U> {
        switch self {
        case .success(let val): return Result<U> { try transform(val) }
        case .failure(let e): return .failure(e)
        }
    }
    
}
