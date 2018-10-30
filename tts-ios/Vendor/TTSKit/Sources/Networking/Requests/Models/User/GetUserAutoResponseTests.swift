//
//  GetUserAutoResponseTests.swift
//  Tests
//
//  Created by Dmitry Nesterenko on 17/07/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import XCTest
import TTSKit

class GetUserAutoResponseTests: XCTestCase {
    
    func testExample() throws {
        let path = Bundle(for: type(of: self)).path(forResource: "GetUserAutoResponseTests", ofType: "json")!
        let string = try String(contentsOfFile: path)
        XCTAssertNoThrow(try JSONResponseMapper<GetUserAutoResponse>().object(for: nil, data: string.data(using: .utf8)!))
    }

}
