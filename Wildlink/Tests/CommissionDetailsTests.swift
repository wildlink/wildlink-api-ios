//
//  CommissionDetailsTests.swift
//  Wildlink-Unit-Tests
//
//  Created by Kyle Kurz on 7/15/19.
//

import XCTest
import Wildlink

class CommissionDetailsTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGoodDictionaryCreatesValidObject() {
        let dictionary: [String : Any] = [
            "ID":            84785,
            "CommissionIDs": [84785],
            "Date":          "2017-12-03T10:29:45Z",
            "Amount":        "0.49",
            "Status":        "READY",
            "Merchant":      "Volcom"
        ]
        let stats: CommissionDetails? = CommissionDetails(dictionary: dictionary)
        XCTAssertNotNil(stats)
    }
    
    func testBadDictionaryCreatesNilObject() {
        let dictionary: [String : Any] = [
            "Peroid": "hour",
            "ClickDate": "2017-09-12T22:00:00Z",
            "ClickCount": 351
        ]
        let stats: CommissionDetails? = CommissionDetails(dictionary: dictionary)
        XCTAssertNil(stats)
    }
    
    func testDictionaryReturn() {
        let dictionary: [String : Any] = [
            "ID":            84785,
            "CommissionIDs": [84785],
            "Date":          "2017-12-03T10:29:45Z",
            "Amount":        "0.49",
            "Status":        "READY",
            "Merchant":      "Volcom"
        ]
        let stats: CommissionDetails? = CommissionDetails(dictionary: dictionary)
        if let returnDictionary = stats?.dictionary {
            XCTAssertEqual(dictionary["ID"] as? Int, returnDictionary["ID"] as? Int)
            XCTAssertEqual(dictionary["CommissionIDs"] as? [Int], returnDictionary["CommissionIDs"] as? [Int])
            XCTAssertEqual(dictionary["Date"] as? String, returnDictionary["Date"] as? String)
            XCTAssertEqual(dictionary["Amount"] as? String, returnDictionary["Amount"] as? String)
            XCTAssertEqual(dictionary["Status"] as? String, returnDictionary["Status"] as? String)
            XCTAssertEqual(dictionary["Merchant"] as? String, returnDictionary["Merchant"] as? String)
        } else {
            XCTFail()
        }
    }
}
