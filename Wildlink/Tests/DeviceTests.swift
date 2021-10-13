//
//  DeviceTests.swift
//  Wildlink-Unit-Tests
//
//  Created by Kyle Kurz - Wildfire on 10/6/21.
//

import Foundation
import XCTest
@testable import Wildlink

class DeviceTests: XCTestCase {
    func testGoodDictionaryCreatesValidObject() {
        let data = """
{"DeviceToken": "abcdef123456", "DeviceKey": "654321", "DeviceID": 12345}
""".data(using: .utf8)!
        let device = try? JSONDecoder().decode(Device.self, from: data)
        XCTAssertNotNil(device)
        XCTAssertEqual(device?.id, 12345)
        XCTAssertEqual(device?.token, "abcdef123456")
        XCTAssertEqual(device?.key, "654321")
    }
    
    func testBadDictionaryCreatesNilObject() {
        let badData = """
{"Period": "hour", "click": "xyz"}
""".data(using: .utf8)!
        let device = try? JSONDecoder().decode(Device.self, from: badData)
        XCTAssertNil(device)
    }
}
