//
//  Wildlink_ExampleTests.swift
//  Wildlink_ExampleTests
//
//  Created by Kyle Kurz on 7/8/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest

class Wildlink_ExampleTests: XCTestCase {
    func testConstantsSecretLeak() {
        XCTAssertEqual(Constants.appId, "<APP_ID>")
        XCTAssertEqual(Constants.appSecret, "<APP_SECRET>")
        
    }
}
