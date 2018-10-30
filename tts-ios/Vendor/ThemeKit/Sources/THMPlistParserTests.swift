//
//  THMPlistParserTests.swift
//  Tests
//
//  Created by Dmitry Nesterenko on 28/06/2018.
//  Copyright © 2018 DZ. All rights reserved.
//

import XCTest
import ThemeKit

class THMPlistParserTests: XCTestCase {
    
    func testParsePlistSuccessfully() {
        let path = Bundle(for: type(of: self)).path(forResource: String(describing: type(of: self)), ofType: "plist")!
        XCTAssertNoThrow(try Theme().parsePlist(path: path))
    }

}
