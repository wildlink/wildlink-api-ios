//
//  VanityURLTests.swift
//  Wildlink
//
//  Created by Kyle Kurz - Wildfire on 10/7/21.
//

import Foundation
import XCTest
@testable import Wildlink

class VanityURLTests: XCTestCase {
    func testGoodDictionaryCreatesValidObject() {
        let data = """
{"OriginalURL": "https://google.com", "VanityURL": "https://wild.link/abcdef"}
""".data(using: .utf8)!
        let vanity = try? JSONDecoder().decode(VanityURL.self, from: data)
        XCTAssertNotNil(vanity)
        XCTAssertEqual(vanity?.originalURL, URL(string: "https://google.com"))
        XCTAssertEqual(vanity?.vanityURL, URL(string: "https://wild.link/abcdef"))
    }
    
    func testBadDictionaryCreatesNilObject() {
        let badData = """
{"Period": "hour", "click": "xyz"}
""".data(using: .utf8)!
        let vanity = try? JSONDecoder().decode(VanityURL.self, from: badData)
        XCTAssertNil(vanity)
    }
}
