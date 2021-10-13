//
//  StringExTests.swift
//  Wildlink-Unit-Tests
//
//  Created by Kyle Kurz - Wildfire on 10/6/21.
//

import CommonCrypto
import Foundation
import XCTest
@testable import Wildlink

class StringExTests: XCTestCase {
    func testStringFromResult() {
        let string = "this is a long string to test"
        let ptr = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: Int(CC_SHA256_DIGEST_LENGTH))
        ptr.initialize(repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        for i in 0..<string.cString(using: .utf8)!.count {
            ptr[i] = CUnsignedChar(string.cString(using: .utf8)![i])
        }
        let result = String.stringFrom(ptr, with: Int(CC_SHA256_DIGEST_LENGTH))
        XCTAssertEqual(result, "746869732069732061206c6f6e6720737472696e6720746f2074657374000000")
    }
    
    func testDigestHMac256() {
        let encoded = "abcdef".digestHMac256(key: "12345")
        XCTAssertNotNil(encoded)
        XCTAssertEqual(encoded, "b00b5b769a95a266310c071c4588687e4296d479f131827bfc59a04f771e2f0d")
    }
}
