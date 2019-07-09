//Tests for the ClickStats object in the Wildlink Cocoapod

import XCTest
import Wildlink

class ClickStatsTests: XCTestCase {
    func goodDictionaryCreatesValidObject() {
        let dictionary: [String : Any] = [
            "Period": "hour",
            "ClickDate": "2017-09-12T22:00:00Z",
            "ClickCount": 351
        ]
        let stats: ClickStats? = ClickStats(dictionary: dictionary)
        XCTAssertNotNil(stats)
    }
}
