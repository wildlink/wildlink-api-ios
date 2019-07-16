//
//  MerchantTests.swift
//  Wildlink-Unit-Tests
//
//  Created by Kyle Kurz on 7/15/19.
//

import XCTest
import Wildlink

class MerchantTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGoodDictionaryCreatesValidObject() {
        let dictionary: [String : Any] = [
            "ID": 5476062,
            "Name": "B.O.R.N. Night Owl Forex Robot",
            "Disabled": true,
            "Featured": false,
            "ShortCode": "2dUB3p3OAgw",
            "ShortURL": "http://example.com/2dUB3p3OAgw",
            "Images": []
        ]
        let stats: Merchant? = Merchant(dictionary: dictionary)
        XCTAssertNotNil(stats)
    }
    
    func testBadDictionaryCreatesNilObject() {
        let dictionary: [String : Any] = [
            "Peroid": "hour",
            "ClickDate": "2017-09-12T22:00:00Z",
            "ClickCount": 351
        ]
        let stats: Merchant? = Merchant(dictionary: dictionary)
        XCTAssertNil(stats)
    }
    
    func testDictionaryReturn() {
        let dictionary: [String : Any] = [
            "ID": 5476062,
            "Name": "B.O.R.N. Night Owl Forex Robot",
            "Disabled": true,
            "Featured": false,
            "ShortCode": "2dUB3p3OAgw",
            "ShortURL": "http://example.com/2dUB3p3OAgw",
            "Images": []
        ]
        let stats: Merchant? = Merchant(dictionary: dictionary)
        if let returnDictionary = stats?.dictionary {
            XCTAssertEqual(dictionary["ID"] as? Int, returnDictionary["ID"] as? Int)
            XCTAssertEqual(dictionary["Name"] as? String, returnDictionary["Name"] as? String)
            XCTAssertEqual(dictionary["Disabled"] as? Bool, returnDictionary["Disabled"] as? Bool)
            XCTAssertEqual(dictionary["Featured"] as? Bool, returnDictionary["Featured"] as? Bool)
            XCTAssertEqual(dictionary["ShortCode"] as? String, returnDictionary["ShortCode"] as? String)
            XCTAssertEqual(dictionary["ShortURL"] as? String, returnDictionary["ShortURL"] as? String)
            XCTAssertEqual(dictionary["Images"] as? [String], returnDictionary["Images"] as? [String])
        } else {
            XCTFail()
        }
    }
}
