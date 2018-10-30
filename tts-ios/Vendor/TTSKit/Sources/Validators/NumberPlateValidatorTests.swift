//
//  NumberPlateValidatorTests.swift
//  Tests
//
//  Created by Dmitry Nesterenko on 27/04/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import XCTest
import TTSKit

class NumberPlateValidatorTests: XCTestCase {

    func testInvalidCharacters() {
        XCTAssertThrowsError(try NumberPlateValidator().validate("Г123ЯЯ12"))
    }
 
    func testValidCharacters() {
        XCTAssertNoThrow(try NumberPlateValidator().validate("А123АА123"))
    }
    
}
