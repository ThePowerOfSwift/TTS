//
//  PhoneNumberTests.swift
//  Tests
//
//  Created by Dmitry Nesterenko on 28/01/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import XCTest
import TTSKit

class PhoneNumberTests: XCTestCase {
    
    func testPhoneNumberShouldInitWithShortFormat() throws {
        let phone = try PhoneNumber(short: "1234567890")
        XCTAssertEqual(phone.rawValue, "1234567890")
    }
    
    func testPhoneNumberShouldThrowWithInvalidShortFormat() throws {
        XCTAssertThrowsError(try PhoneNumber(short: "12345678900"))
    }
    
    func testPhoneNumberShouldInitWithFreeFormat() throws {
        let phone = try PhoneNumber(free: "88001234567")
        XCTAssertEqual(phone.rawValue, "88001234567")
    }
    
    func testPhoneNumberShouldThrowWithInvalidFreeFormat() throws {
        XCTAssertThrowsError(try PhoneNumber(free: "8001234567"))
    }

    func testPhoneNumberShouldInitWithFullFormat() throws {
        let phone = try PhoneNumber(full: "+7 (999) 123-45-67")
        XCTAssertEqual(phone.rawValue, "+79991234567")
    }
    
    func testPhoneNumberShouldThrowWithInvalidFullFormat() throws {
        XCTAssertThrowsError(try PhoneNumber(free: "+7 (999) 123-45-6"))
    }
    
}
