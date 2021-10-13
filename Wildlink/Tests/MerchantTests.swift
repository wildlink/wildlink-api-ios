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
        let data = """
    {
      "ID": 8969,
      "Name": "MAGIX u0026 VEGAS Creative Software",
      "Disabled": false,
      "Featured": false,
      "ShortCode": "uOpXiUYg",
      "ShortURL": "https://dev.wild.link/uOpXiUYg",
      "BrowserExtensionDisabled": false,
      "CashbackDisabled": false,
      "ShareAndEarnDisabled": false,
      "DeeplinkDisabled": false,
      "Images": [
        {
          "ID": 1226,
          "Kind": "LOGO",
          "Ordinal": 1,
          "ImageID": 1227,
          "URL": "https://dev-images.wildlink.me/wl-image/e6bf024f8ebfdb49fc7926b2fac620c4b069e64e.jpeg",
          "Width": 200,
          "Height": 200
        }
      ]
    }
""".data(using: .utf8)!
        let merchant = try? JSONDecoder().decode(Merchant.self, from: data)
        XCTAssertNotNil(merchant)
    }
    
    func testBadDictionaryCreatesNilObject() {
        let badData = """
{"Period": "hour", "click": "xyz"}
""".data(using: .utf8)!
        let merchant = try? JSONDecoder().decode(Merchant.self, from: badData)
        XCTAssertNil(merchant)
    }
}
