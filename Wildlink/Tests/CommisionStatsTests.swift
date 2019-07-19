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
        let dictionary: [String : Any] = [
            "PendingAmount": "0.49",
            "ReadyAmount": "0.25",
            "PaidAmount": "3.62"
        ]
        let stats: CommissionStats? = CommissionStats(dictionary: dictionary)
        XCTAssertNotNil(stats)
    }
    
    func testBadDictionaryCreatesNilObject() {
        let dictionary: [String : Any] = [
            "Peroid": "hour",
            "ClickDate": "2017-09-12T22:00:00Z",
            "ClickCount": 351
        ]
        let stats: CommissionStats? = CommissionStats(dictionary: dictionary)
        XCTAssertNil(stats)
    }
    
    func testDictionaryReturn() {
        let dictionary: [String : Any] = [
            "PendingAmount": "0.49",
            "ReadyAmount": "0.25",
            "PaidAmount": "3.62"
        ]
        let stats: CommissionStats? = CommissionStats(dictionary: dictionary)
        if let returnDictionary = stats?.dictionary {
            XCTAssertEqual(dictionary["PendingAmount"] as? String, returnDictionary["PendingAmount"] as? String)
            XCTAssertEqual(dictionary["ReadyAmount"] as? String, returnDictionary["ReadyAmount"] as? String)
            XCTAssertEqual(dictionary["PaidAmount"] as? Int, returnDictionary["PaidAmount"] as? Int)
        } else {
            XCTFail()
        }
    }
}
