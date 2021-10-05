//
//  CommissionDetailTests.swift
//  Wildlink-Unit-Tests
//
//  Created by Kyle Kurz on 7/15/19.
//

import XCTest
import Wildlink

class CommissionDetailTests: XCTestCase {
    let decoder = JSONDecoder()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        decoder.dateDecodingStrategy = .iso8601
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGoodDictionaryCreatesValidObject() {
        let data = """
{"ID": 84785, "CommissionIDs": [84785], "Date": "2017-12-03T10:29:45Z", "Amount": "0.49", "Status": "READY", "Merchant": "Volcom"}
""".data(using: .utf8)!
        let details = try? decoder.decode(CommissionDetail.self, from: data)
        XCTAssertNotNil(details)
        XCTAssertEqual(details?.id, 84785)
        XCTAssertEqual(details?.commissionIds, [84785])
        XCTAssertEqual(details?.date.utc, "2017-12-03T10:29:45Z")
        XCTAssertEqual(details?.amount, "0.49")
        XCTAssertEqual(details?.status, .ready)
        XCTAssertEqual(details?.merchant, "Volcom")
    }
    
    func testBadDictionaryCreatesNilObject() {
        let badData = """
{"Period": "hour", "click": "xyz"}
""".data(using: .utf8)!
        let details = try? decoder.decode(CommissionDetail.self, from: badData)
        XCTAssertNil(details)
    }
}
