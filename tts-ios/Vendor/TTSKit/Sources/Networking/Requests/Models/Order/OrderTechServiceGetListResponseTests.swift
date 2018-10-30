//
//  OrderTechServiceGetListResponseTests.swift
//  Tests
//
//  Created by Dmitry Nesterenko on 06/06/2018.
//  Copyright © 2018 Dmitry Nesterenko. All rights reserved.
//

import XCTest
import TTSKit

class OrderTechServiceGetListResponseTests: XCTestCase {
    
    func testOrderTechServiceGetListResponseServiceAccessors() throws {
        let string = """
{
    "name": "ТО-23(23 года или 345 тыс. км)",
    "uid": "22sdsds"
}
"""
        
        let object = try JSONDecoder().decode(OrderTechServiceGetListResponse.Service.self, from: string.data(using: .utf8)!)
        XCTAssertEqual(object.title, "ТО-23")
        XCTAssertEqual(object.date, "23 года или")
        XCTAssertEqual(object.mileage, "345 тыс. км")
    }
    
}
