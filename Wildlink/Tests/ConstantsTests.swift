//
//  ConstantsTests.swift
//  Wildlink-Unit-Tests
//
//  Created by Kyle Kurz - Wildfire on 10/6/21.
//

import Foundation
import XCTest
@testable import Wildlink

class ConstantsTests: XCTestCase {
    func testBaseUrlProd() {
        XCTAssertEqual(APIConstants.baseUrlProd , URL(string: "https://api.wfi.re/v2"))
    }
    
    func testBaseUrlDev() {
        XCTAssertEqual(APIConstants.baseUrlDev, URL(string: "https://dev-api.wfi.re/v2"))
    }
}
