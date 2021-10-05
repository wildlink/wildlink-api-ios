//
//  ImageTests.swift
//  Wildlink-Unit-Tests
//
//  Created by Kyle Kurz - Wildfire on 10/6/21.
//

import Foundation
import XCTest
@testable import Wildlink

class ImageTests: XCTestCase {
    func testGoodDictionaryCreatesValidObject() {
        let data = """
{"ID": 1508, "Kind": "LOGO", "Ordinal": 1, "ImageID": 1509, "URL": "https://dev-images.wildlink.me/wl-image/ecf9466c132d140bcc1af7bf74cb8c20fde1ebe3.jpeg", "Width": 200, "Height": 200}
""".data(using: .utf8)!
        let image = try? JSONDecoder().decode(Image.self, from: data)
        XCTAssertNotNil(image)
        XCTAssertEqual(image?.id, 1508)
        XCTAssertEqual(image?.height, 200)
        XCTAssertEqual(image?.width, 200)
        XCTAssertEqual(image?.ordinal, 1)
        XCTAssertEqual(image?.imageId, 1509)
        XCTAssertEqual(image?.kind, .logo)
    }
    
    func testGoodDictionaryCreatesValidObjectFeaturedImage() {
        let data = """
{"ID": 1508, "Kind": "FEATURED", "Ordinal": 1, "ImageID": 1509, "URL": "https://dev-images.wildlink.me/wl-image/ecf9466c132d140bcc1af7bf74cb8c20fde1ebe3.jpeg", "Width": 200, "Height": 200}
""".data(using: .utf8)!
        let image = try? JSONDecoder().decode(Image.self, from: data)
        XCTAssertNotNil(image)
        XCTAssertEqual(image?.id, 1508)
        XCTAssertEqual(image?.height, 200)
        XCTAssertEqual(image?.width, 200)
        XCTAssertEqual(image?.ordinal, 1)
        XCTAssertEqual(image?.imageId, 1509)
        XCTAssertEqual(image?.kind, .featured)
    }
    
    func testGoodDictionaryCreatesValidObjectGeneralImage() {
        let data = """
{"ID": 1508, "Kind": "GENERAL", "Ordinal": 1, "ImageID": 1509, "URL": "https://dev-images.wildlink.me/wl-image/ecf9466c132d140bcc1af7bf74cb8c20fde1ebe3.jpeg", "Width": 200, "Height": 200}
""".data(using: .utf8)!
        let image = try? JSONDecoder().decode(Image.self, from: data)
        XCTAssertNotNil(image)
        XCTAssertEqual(image?.id, 1508)
        XCTAssertEqual(image?.height, 200)
        XCTAssertEqual(image?.width, 200)
        XCTAssertEqual(image?.ordinal, 1)
        XCTAssertEqual(image?.imageId, 1509)
        XCTAssertEqual(image?.kind, .general)
    }
    
    func testBadDictionaryCreatesNilObject() {
        let badData = """
{"Period": "hour", "click": "xyz"}
""".data(using: .utf8)!
        let image = try? JSONDecoder().decode(Image.self, from: badData)
        XCTAssertNil(image)
    }
}
