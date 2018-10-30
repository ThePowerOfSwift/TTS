//
//  ServerDateTransformerTests.swift
//  Tests
//
//  Created by Dmitry Nesterenko on 15/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import XCTest
@testable import TTSKit

class ServerDateTransformerTests: XCTestCase {
    
    func testSuccess() throws {
        let transformer = ServerDateTransformer()
        let string = "2018-06-13 17:00:00"
        XCTAssertNoThrow(try transformer.date(from: string))
    }
    
}
