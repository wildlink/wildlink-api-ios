//
//  CommisionStatsTests.swift
//  Wildlink-Unit-Tests
//
//  Created by Kyle Kurz on 7/15/19.
//

import XCTest
import Wildlink

class CommissionStatsTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGoodDictionaryCreatesValidObject() {
        let data = """
{"PendingAmount": "0.49", "ReadyAmount": "0.25", "PaidAmount": "3.62"}
""".data(using: .utf8)!
        let stats = try? JSONDecoder().decode(CommissionStats.self, from: data)
        XCTAssertNotNil(stats)
        XCTAssertEqual(stats?.pendingAmount, "0.49")
        XCTAssertEqual(stats?.readyAmount, "0.25")
        XCTAssertEqual(stats?.paidAmount, "3.62")
    }
    
    func testBadDictionaryCreatesNilObject() {
        let badData = """
{"Period": "hour", "click": "xyz"}
""".data(using: .utf8)!
        let stats = try? JSONDecoder().decode(CommissionStats.self, from: badData)
        XCTAssertNil(stats)
    }
}
