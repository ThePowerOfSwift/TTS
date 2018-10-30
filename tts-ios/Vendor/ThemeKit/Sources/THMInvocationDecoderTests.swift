//
//  THMInvocationDecoderTests.swift
//  Tests
//
//  Created by Dmitry Nesterenko on 28/06/2018.
//  Copyright © 2018 DZ. All rights reserved.
//

import XCTest
import ThemeKit

class THMInvocationDecoderTests: XCTestCase {
    
    func testInvocationObjectShouldThrowOnInvalidNumberOfArguments() {
        let object = ["setTitleColor:forState:"] as [Any]
        XCTAssertThrowsError(try InvocationDecoder().invocation(target: UIButton.appearance(), object: object))
    }
    
    func testInvocationObjectShouldContainValidMethodSignature() {
        let object = ["invalidSelector:", "arg1"] as [Any]
        XCTAssertThrowsError(try InvocationDecoder().invocation(target: UIButton.appearance(), object: object))
    }
    
    func testSuccessfullInvocationDecoding() {
        let object = ["setTitleColor:forState:",
                      ["THMStringToColorTransformer", "aabbccdd"],
                      0] as [Any]
        XCTAssertNoThrow(try InvocationDecoder().invocation(target: UIButton.appearance(), object: object))
    }
    
}
