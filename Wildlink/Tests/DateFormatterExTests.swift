//
//  DateFormatterExTests.swift
//  Alamofire
//
//  Created by Kyle Kurz on 7/9/19.
//

import Foundation
import XCTest
import Wildlink

class DateFormatterExTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUTCDateFromString() {
        let string = "1970-01-01T00:00:00Z"
        let date = string.dateFromUTC
        XCTAssertEqual(date, Date.init(timeIntervalSince1970: 0))
    }
    
    func testUTCStringFromDate() {
        let date = Date.init(timeIntervalSince1970: 0)
        let string = date.utc
        XCTAssertEqual(string, "1970-01-01T00:00:00Z")
    }
    
    func testISO8601DateFromString() {
        let string = "1970-01-01T00:00:00.000Z"
        let date = string.dateFromISO8601
        XCTAssertEqual(date, Date.init(timeIntervalSince1970: 0))
    }
    
    func testISO8601StringFromDate() {
        let date = Date.init(timeIntervalSince1970: 0)
        let string = date.iso8601
        XCTAssertEqual(string, "1970-01-01T00:00:00.000Z")
    }
}
