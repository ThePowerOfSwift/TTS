//
//  THMAppearanceDecoderTests.swift
//  Tests
//
//  Created by Dmitry Nesterenko on 28/06/2018.
//  Copyright © 2018 DZ. All rights reserved.
//

import XCTest
import ThemeKit

class THMAppearanceDecoderTests: XCTestCase {
    
    func testFirstClassInKeyPathShouldConformToUIAppearanceContainerProtocol() {
        XCTAssertThrowsError(try AppearanceDecoder().appearanceFromKeyPath("NSNotificationCenter/UIButton"))
    }
    
    func testLastClassInKeyPathShouldConformToUIAppearanceProtocol() {
        XCTAssertThrowsError(try AppearanceDecoder().appearanceFromKeyPath("UIView/NSObject"))
    }
    
    func testShouldThrowErrorForUndefinedClass() {
        XCTAssertThrowsError(try AppearanceDecoder().appearanceFromKeyPath("UndefinedClass"))
    }
    
    func testAppearanceFromSingleClassInKeyPathSucceeded() {
        XCTAssertNoThrow(try AppearanceDecoder().appearanceFromKeyPath("UIButton"))
    }
    
    func testAppearanceFromValidKeyPathSucceeded() {
        XCTAssertNoThrow(try AppearanceDecoder().appearanceFromKeyPath("UIViewController/UIButton"))
    }
    
}
