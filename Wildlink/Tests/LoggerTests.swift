//
//  LoggerTests.swift
//  Wildlink-Unit-Tests
//
//  Created by Kyle Kurz on 7/18/19.
//

import XCTest
@testable import Wildlink

class LoggerTests: XCTestCase {
    func testLoggerInitializer() {
        let logger = Logger.init()
        XCTAssertNotNil(logger)
    }
    
    func testLoggerInfoCall() {
        XCTAssertNoThrow(Logger.info("Test string"))
    }
    
    func testLoggerErrorCall() {
        XCTAssertNoThrow(Logger.error("Test string"))
    }
    
}
