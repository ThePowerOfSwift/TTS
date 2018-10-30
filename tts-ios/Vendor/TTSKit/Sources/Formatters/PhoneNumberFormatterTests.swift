//
//  PhoneNumberFormatterTests.swift
//  Tests
//
//  Created by Dmitry Nesterenko on 01/04/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import XCTest
import TTSKit

class PhoneNumberFormatterTests: XCTestCase {
    
    func testPhoneNumberFormatterShouldReturnFormattedStringWithSpecialCharactersForValidShortPhoneNumber() throws {
        let phone = try PhoneNumber(short: "9991234567")
        let result = PhoneNumberFormatter().string(from: phone)
        XCTAssertEqual(result, "+7 (999) 123-45-67")
    }
    
    func testPhoneNumberFormatterShouldReturnFormattedStringForValidFreePhoneNumber() throws {
        let phone = try PhoneNumber(free: "88001234567")
        let result = PhoneNumberFormatter().string(from: phone)
        XCTAssertEqual(result, "8 800 123 45 67")
    }
    
    func testPhoneNumberFormatterShouldReturnFormattedStringForValidFullPhoneNumber() throws {
        let phone = try PhoneNumber(full: "+7 (999) 123-45-67")
        let result = PhoneNumberFormatter().string(from: phone)
        XCTAssertEqual(result, "+7 (999) 123-45-67")
    }
    
    func testPhoneNumberFormatterShouldReturnApiRequestFormattedStringForValidFullPhoneNumber() throws {
        let phone = try PhoneNumber(full: "+7 (999) 123-45-67")
        let result = try PhoneNumberFormatter().apiRequestString(from: phone)
        XCTAssertEqual(result, "+7(999)123-45-67")
    }
    
}
