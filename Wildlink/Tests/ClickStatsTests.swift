//Tests for the ClickStats object in the Wildlink Cocoapod

import XCTest
import Wildlink

class ClickStatsTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGoodDictionaryCreatesValidObject() {
        let dictionary: [String : Any] = [
            "Period": "hour",
            "ClickDate": "2017-09-12T22:00:00Z",
            "ClickCount": 351
        ]
        let stats: ClickStats? = ClickStats(dictionary: dictionary)
        XCTAssertNotNil(stats)
    }
    
    func testBadDictionaryCreatesNilObject() {
        let dictionary: [String : Any] = [
            "Peroid": "hour",
            "ClickDate": "2017-09-12T22:00:00Z",
            "ClickCount": 351
        ]
        let stats: ClickStats? = ClickStats(dictionary: dictionary)
        XCTAssertNil(stats)
    }
    
    func testDictionaryReturn() {
        let dictionary: [String : Any] = [
            "Period": "hour",
            "ClickDate": "2017-09-12T22:00:00Z",
            "ClickCount": 351
        ]
        let stats: ClickStats? = ClickStats(dictionary: dictionary)
        if let returnDictionary = stats?.dictionary {
            XCTAssertEqual(dictionary["Period"] as? String, returnDictionary["Period"] as? String)
            XCTAssertEqual(dictionary["ClickDate"] as? String, returnDictionary["ClickDate"] as? String)
            XCTAssertEqual(dictionary["ClickCount"] as? Int, returnDictionary["ClickCount"] as? Int)
        } else {
            XCTFail()
        }
    }
}
