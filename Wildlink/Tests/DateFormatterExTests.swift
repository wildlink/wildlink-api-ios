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
        let string = "2017-09-12T22:00:00Z"
        //needs updated to test the actual date object that's returned
        guard let _ = string.dateFromUTC else {
            return XCTFail()
        }
    }
}
