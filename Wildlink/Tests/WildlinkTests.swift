//
//  WildlinkTests.swift
//  Wildlink-Unit-Tests
//
//  Created by Kyle Kurz on 7/15/19.
//

import XCTest
import Alamofire
import OHHTTPStubs
@testable import Wildlink

class WildlinkTests: XCTestCase, WildlinkDelegate {
    var expectToken: XCTestExpectation?
    func didReceive(deviceToken: String) {
        tokenReceived = true
        expectToken?.fulfill()
    }
    
    var expectKey: XCTestExpectation?
    func didReceive(deviceKey: String) {
        keyReceived = true
        expectKey?.fulfill()
    }
    
    var expectId: XCTestExpectation?
    func didReceive(deviceId: UInt64) {
        idReceived = true
        expectId?.fulfill()
    }
    
    var idReceived = false
    var tokenReceived = false
    var keyReceived = false
    
    enum WildlinkTestError: Error {
        case generic
    }
    
    override func setUp() {
        Wildlink.shared.isRefreshing = false
        Wildlink.shared.deviceKey = nil
        HTTPStubs.onStubMissing { request in
            print("Missing stub for \(String(describing: request.url?.absoluteURL))")
        }
        idReceived = false
        tokenReceived = false
        keyReceived = false
        Wildlink.shared.delegate = self
    }
    
    override func tearDown() {
        URLCache.shared.removeAllCachedResponses()
        Wildlink.apiKey = ""
        Wildlink.appID = ""
    }
    
    func testSharedObject() {
        let wildlink = Wildlink.shared
        XCTAssertNotNil(wildlink)
        XCTAssertNotNil(wildlink.lock)
        XCTAssertNotNil(wildlink.decoder)
        XCTAssertEqual(wildlink.baseUrl, APIConstants.baseUrlProd)
    }
    
    func testInitializerWithToken() {
        XCTAssertFalse(tokenReceived)
        XCTAssertFalse(keyReceived)
        XCTAssertFalse(idReceived)
        Wildlink.shared.initialize(appId: "abc", appSecret: "def", wildlinkDeviceToken: "123456", wildlinkDeviceKey: "654321")
        XCTAssertTrue(tokenReceived)
        XCTAssertFalse(keyReceived)
        XCTAssertFalse(idReceived)
    }
    
    func testInitializerNoToken() {
        expectToken = expectation(description: "Token receieved")
        expectKey = expectation(description: "Key received")
        expectId = expectation(description: "Id received")
        stub(condition: isPath("/v2/device"), response: { _ in
            return HTTPStubsResponse(jsonObject: ["DeviceID": 123456, "DeviceToken": "abcdef123456", "DeviceKey": "abcdef"], statusCode: 200, headers: ["Content-Type": "application/json", "Cache-Control": "no-cache"])
        })
        XCTAssertFalse(tokenReceived)
        XCTAssertFalse(keyReceived)
        XCTAssertFalse(idReceived)
        Wildlink.shared.initialize(appId: "abc", appSecret: "def")
        guard let expectId = expectId, let expectToken = expectToken, let expectKey = expectKey else {
            XCTFail()
            return
        }
        wait(for: [expectToken, expectKey, expectId], timeout: 3.0)
    }
    
    func testCreateVanityURL() {
        let data = """
{"OriginalURL": "https://google.com", "VanityURL": "https://wild.link/12345"}
""".data(using: .utf8)!
        stub(condition: isPath("/v2/vanity"), response: { _ in
            return HTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/json", "Cache-Control": "no-cache"])
        })
        let expect = expectation(description: "Completion block called")
        Wildlink.shared.createVanityURL(from: URL(string: "https://google.com")!, { vanity, error in
            XCTAssertNil(error)
            XCTAssertNotNil(vanity)
            XCTAssertEqual(vanity?.originalURL.absoluteString, "https://google.com")
            XCTAssertEqual(vanity?.vanityURL.absoluteString, "https://wild.link/12345")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 3.0)
    }
    
    func testCreateVanityURLMalformedResponse() {
        let data = """
{"OriginalURL": "https://google.com", "VantiyURL": "https://wild.link/12345"}
""".data(using: .utf8)!
        stub(condition: isPath("/v2/vanity"), response: { _ in
            return HTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/json", "Cache-Control": "no-cache"])
        })
        let expect = expectation(description: "Completion block called")
        Wildlink.shared.createVanityURL(from: URL(string: "https://google.com")!, { vanity, error in
            XCTAssertNil(vanity)
            XCTAssertNotNil(error)
            switch error?.kind {
            case .invalidURL:
                XCTFail()
            case .invalidResponse:
                XCTFail()
            case .serverError(_):
                print("Valid")
            case .none:
                XCTFail()
            }
            expect.fulfill()
        })
        wait(for: [expect], timeout: 3.0)
    }
    
    func testCreateVanityURLWithString() {
        let data = """
{"OriginalURL": "https://google.com", "VanityURL": "https://wild.link/12345"}
""".data(using: .utf8)!
        stub(condition: isPath("/v2/vanity"), response: { _ in
            return HTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/json", "Cache-Control": "no-cache"])
        })
        let expect = expectation(description: "Completion block called")
        Wildlink.shared.createVanityURL(from: "https://google.com", { vanity, error in
            XCTAssertNil(error)
            XCTAssertNotNil(vanity)
            XCTAssertEqual(vanity?.originalURL.absoluteString, "https://google.com")
            XCTAssertEqual(vanity?.vanityURL.absoluteString, "https://wild.link/12345")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 3.0)
    }
    
    func testCreateVanityURLWithBadString() {
        let data = """
{"OriginalURL": "https://google.com", "VanityURL": "https://wild.link/12345"}
""".data(using: .utf8)!
        stub(condition: isPath("/v2/vanity"), response: { _ in
            return HTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/json", "Cache-Control": "no-cache"])
        })
        let expect = expectation(description: "Completion block called")
        Wildlink.shared.createVanityURL(from: "not a url", { vanity, error in
            XCTAssertNil(vanity)
            XCTAssertNotNil(error)
            switch error?.kind {
            case .invalidURL:
                print("Valid")
            case .invalidResponse:
                XCTFail()
            case .serverError(_):
                XCTFail()
            case .none:
                XCTFail()
            }
            expect.fulfill()
        })
        wait(for: [expect], timeout: 3.0)
    }
    
    func testCommissionSummary() {
        let data = """
{"PendingAmount": "0.49", "ReadyAmount": "0.25", "PaidAmount": "3.62"}
""".data(using: .utf8)!
        stub(condition: isPath("/v2/device/stats/commission-summary"), response: { _ in
            return HTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/json", "Cache-Control": "no-cache"])
        })
        let expect = expectation(description: "Completion block called")
        Wildlink.shared.getCommissionSummary( { stats, error in
            XCTAssertNil(error)
            XCTAssertNotNil(stats)
            XCTAssertEqual(stats?.pendingAmount, "0.49")
            XCTAssertEqual(stats?.readyAmount, "0.25")
            XCTAssertEqual(stats?.paidAmount, "3.62")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 3.0)
    }
    
    func testCommissionSummaryMalformedData() {
        let data = """
{"PendingAmount": 0.49, "ReadyAmount": 0.25, "PaidAmount": 3.62}
""".data(using: .utf8)!
        stub(condition: isPath("/v2/device/stats/commission-summary"), response: { _ in
            return HTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/json", "Cache-Control": "no-cache"])
        })
        let expect = expectation(description: "Completion block called")
        Wildlink.shared.getCommissionSummary( { stats, error in
            XCTAssertNil(stats)
            XCTAssertNotNil(error)
            switch error?.kind {
            case .invalidURL:
                XCTFail()
            case .invalidResponse:
                XCTFail()
            case .serverError(_):
                print("Valid")
            case .none:
                XCTFail()
            }
            expect.fulfill()
        })
        wait(for: [expect], timeout: 3.0)
    }
    
    func testGetCommissionDetails() {
        let data = """
[{"ID": 84785, "CommissionIDs": [84785], "Date": "2017-12-03T10:29:45Z", "Amount": "0.49", "Status": "READY", "Merchant": "Volcom"}]
""".data(using: .utf8)!
        stub(condition: isPath("/v2/device/stats/commission-detail"), response: { _ in
            return HTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/json", "Cache-Control": "no-cache"])
        })
        let expect = expectation(description: "Completion block called")
        Wildlink.shared.getCommissionDetails( { commissions, error in
            XCTAssertNil(error)
            XCTAssertEqual(commissions.count, 1)
            guard let details = commissions.first else {
                XCTFail()
                return
            }
            XCTAssertNotNil(details)
            XCTAssertEqual(details.id, 84785)
            XCTAssertEqual(details.commissionIds, [84785])
            XCTAssertEqual(details.date.utc, "2017-12-03T10:29:45Z")
            XCTAssertEqual(details.amount, "0.49")
            XCTAssertEqual(details.status, .ready)
            XCTAssertEqual(details.merchant, "Volcom")
            expect.fulfill()
        })
        wait(for: [expect], timeout: 3.0)
    }
    
    func testGetCommissionDetailsMalformedResponse() {
        let data = """
[{"ID": 84785, "CommissionIDs": [84785], "Data": "2017-12-03T10:29:45Z", "Amount": "0.49", "Status": "READY", "Merchant": "Volcom"}]
""".data(using: .utf8)!
        stub(condition: isPath("/v2/device/stats/commission-detail"), response: { _ in
            return HTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/json", "Cache-Control": "no-cache"])
        })
        let expect = expectation(description: "Completion block called")
        Wildlink.shared.getCommissionDetails( { commissions, error in
            XCTAssertNotNil(error)
            XCTAssertEqual(commissions.count, 0)
            switch error?.kind {
            case .invalidURL:
                XCTFail()
            case .invalidResponse:
                XCTFail()
            case .serverError(_):
                print("Valid")
            case .none:
                XCTFail()
            }
            expect.fulfill()
        })
        wait(for: [expect], timeout: 3.0)
    }
    
    func testSearchMerchants() {
        let data = """
    { "Merchants": [{
      "ID": 123,
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
    }]}
""".data(using: .utf8)!
        stub(condition: isPath("/v2/merchant"), response: { _ in
            return HTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/json", "Cache-Control": "no-cache"])
        })
        let expect = expectation(description: "Completion block called")
        Wildlink.shared.searchMerchants(ids: ["123"], names: [], q: nil, disabled: nil, featured: nil, sortBy: nil, sortOrder: nil, limit: nil, { merchants, error in
            XCTAssertNil(error)
            XCTAssertNotNil(merchants)
            XCTAssertEqual(merchants.count, 1)
            XCTAssertEqual(merchants.first?.id, 123)
            XCTAssertEqual(merchants.first?.featured, false)
            XCTAssertEqual(merchants.first?.shortURL, URL(string: "https://dev.wild.link/uOpXiUYg"))
            expect.fulfill()
        })
        wait(for: [expect], timeout: 3.0)
    }
    
    func testSearchMerchantsAllParameters() {
        let data = """
    { "Merchants": [{
      "ID": 123,
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
    }]}
""".data(using: .utf8)!
        stub(condition: isPath("/v2/merchant"), response: { _ in
            return HTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/json", "Cache-Control": "no-cache"])
        })
        let expect = expectation(description: "Completion block called")
        Wildlink.shared.searchMerchants(ids: ["123"], names: [], q: "abc", disabled: true, featured: true, sortBy: .name, sortOrder: .ascending, limit: 10, { merchants, error in
            XCTAssertNil(error)
            XCTAssertNotNil(merchants)
            XCTAssertEqual(merchants.count, 1)
            XCTAssertEqual(merchants.first?.id, 123)
            XCTAssertEqual(merchants.first?.featured, false)
            XCTAssertEqual(merchants.first?.shortURL, URL(string: "https://dev.wild.link/uOpXiUYg"))
            expect.fulfill()
        })
        wait(for: [expect], timeout: 3.0)
    }
    
    func testSearchMerchantsAllParametersFalse() {
        let data = """
    { "Merchants": [{
      "ID": 123,
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
    }]}
""".data(using: .utf8)!
        stub(condition: isPath("/v2/merchant"), response: { _ in
            return HTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/json", "Cache-Control": "no-cache"])
        })
        let expect = expectation(description: "Completion block called")
        Wildlink.shared.searchMerchants(ids: ["123"], names: ["MAGIX u0026 VEGAS Creative Software"], q: "abc", disabled: false, featured: false, sortBy: .name, sortOrder: .ascending, limit: 10, { merchants, error in
            XCTAssertNil(error)
            XCTAssertNotNil(merchants)
            XCTAssertEqual(merchants.count, 1)
            XCTAssertEqual(merchants.first?.id, 123)
            XCTAssertEqual(merchants.first?.featured, false)
            XCTAssertEqual(merchants.first?.shortURL, URL(string: "https://dev.wild.link/uOpXiUYg"))
            expect.fulfill()
        })
        wait(for: [expect], timeout: 3.0)
    }
    
    func testSearchMerchantsBadResponse() {
        let data = """
    { "WildlinkError": "Invalid input"}
""".data(using: .utf8)!
        stub(condition: isPath("/v2/merchant"), response: { _ in
            return HTTPStubsResponse(data: data, statusCode: 406, headers: ["Content-Type": "application/json", "Cache-Control": "no-cache"])
        })
        let expect = expectation(description: "Completion block called")
        Wildlink.shared.searchMerchants(ids: ["123"], names: ["MAGIX u0026 VEGAS Creative Software"], q: "abc", disabled: false, featured: false, sortBy: .name, sortOrder: .ascending, limit: 10, { merchants, error in
            XCTAssertEqual(merchants.count, 0)
            XCTAssertNotNil(error)
            switch error?.kind {
            case .invalidURL:
                XCTFail()
            case .invalidResponse:
                XCTFail()
            case .serverError(_):
                print("Valid")
            case .none:
                XCTFail()
            }
            expect.fulfill()
        })
        wait(for: [expect], timeout: 3.0)
    }
    
    func testGetMerchantById() {
        let data = """
    {
      "ID": 123,
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
        stub(condition: isPath("/v2/merchant/123"), response: { _ in
            return HTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/json", "Cache-Control": "no-cache"])
        })
        let expect = expectation(description: "Completion block called")
        Wildlink.shared.getMerchantBy("123", { merchant, error in
            XCTAssertNil(error)
            XCTAssertNotNil(merchant)
            XCTAssertEqual(merchant?.id, 123)
            XCTAssertEqual(merchant?.featured, false)
            XCTAssertEqual(merchant?.shortURL, URL(string: "https://dev.wild.link/uOpXiUYg"))
            expect.fulfill()
        })
        wait(for: [expect], timeout: 3.0)
    }
    
    func testGetMerchantByIdBadData() {
        let data = """
        """.data(using: .utf8)!
        stub(condition: isPath("/v2/merchant/123"), response: { _ in
            return HTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/json", "Cache-Control": "no-cache"])
        })
        let expect = expectation(description: "Completion block called")
        Wildlink.shared.getMerchantBy("123", { merchant, error in
            XCTAssertNil(merchant)
            XCTAssertNotNil(error)
            switch error?.kind {
            case .invalidURL:
                XCTFail()
            case .invalidResponse:
                XCTFail()
            case .serverError(_):
                print("Valid")
            case .none:
                XCTFail()
            }
            expect.fulfill()
        })
        wait(for: [expect], timeout: 3.0)
    }
    
    func testRefreshDeviceToken() {
        stub(condition: isPath("/v2/device"), response: { _ in
            return HTTPStubsResponse(jsonObject: ["DeviceID": 123456, "DeviceToken": "abcdef123456", "DeviceKey": "abcdef"], statusCode: 200, headers: ["Content-Type": "application/json", "Cache-Control": "no-cache"])
        })
        let expect = expectation(description: "Completion block called")
        Wildlink.shared.refreshDeviceToken { succeeded, deviceToken, deviceKey, deviceId in
            XCTAssertEqual(succeeded, true)
            XCTAssertEqual(deviceToken, "abcdef123456")
            XCTAssertEqual(deviceKey, "abcdef")
            XCTAssertEqual(deviceId, 123456)
            expect.fulfill()
        }
        wait(for: [expect], timeout: 3.0)
    }
    
    func testRefreshDeviceTokenExistingDeviceKey() {
        stub(condition: isPath("/v2/device"), response: { _ in
            return HTTPStubsResponse(jsonObject: ["DeviceID": 123456, "DeviceToken": "abcdef123456", "DeviceKey": "wxyz"], statusCode: 200, headers: ["Content-Type": "application/json", "Cache-Control": "no-cache"])
        })
        Wildlink.shared.deviceKey = "wxyz"
        let expect = expectation(description: "Completion block called")
        Wildlink.shared.refreshDeviceToken { succeeded, deviceToken, deviceKey, deviceId in
            XCTAssertEqual(succeeded, true)
            XCTAssertEqual(deviceToken, "abcdef123456")
            XCTAssertEqual(deviceKey, "wxyz")
            XCTAssertEqual(deviceId, 123456)
            expect.fulfill()
        }
        wait(for: [expect], timeout: 3.0)
    }
    
    func testRefreshDeviceTokenAlreadyRefreshing() {
        stub(condition: isPath("/v2/device"), response: { _ in
            return HTTPStubsResponse(jsonObject: ["DeviceID": 123456, "DeviceToken": "abcdef123456", "DeviceKey": "abcdef"], statusCode: 200, headers: ["Content-Type": "application/json", "Cache-Control": "no-cache"])
        })
        let expect = expectation(description: "Completion block called")
        expect.isInverted = true
        Wildlink.shared.isRefreshing = true
        Wildlink.shared.refreshDeviceToken { succeeded, deviceToken, deviceKey, deviceId in
            XCTAssertEqual(succeeded, true)
            XCTAssertEqual(deviceToken, "abcdef123456")
            XCTAssertEqual(deviceKey, "abcdef")
            XCTAssertEqual(deviceId, 123456)
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1.0)
    }
    
    func testRefreshDeviceTokenBadResponse() {
        stub(condition: isPath("/v2/device"), response: { _ in
            return HTTPStubsResponse(jsonObject: ["DeviecID": 123456, "DeviceToken": "abcdef123456", "DeviceKey": "abcdef"], statusCode: 200, headers: ["Content-Type": "application/json", "Cache-Control": "no-cache"])
        })
        let expect = expectation(description: "Completion block called")
        Wildlink.shared.refreshDeviceToken { succeeded, deviceToken, deviceKey, deviceId in
            XCTAssertEqual(succeeded, false)
            XCTAssertEqual(deviceToken, nil)
            XCTAssertEqual(deviceKey, nil)
            XCTAssertEqual(deviceId, nil)
            expect.fulfill()
        }
        wait(for: [expect], timeout: 3.0)
    }
    
    func testRefreshDeviceTokenServerError() {
        stub(condition: isPath("/v2/device"), response: { _ in
            return HTTPStubsResponse(jsonObject: ["DeviceID": 123456, "DeviceToken": "abcdef123456", "DeviceKey": "abcdef"], statusCode: 404, headers: ["Content-Type": "application/json", "Cache-Control": "no-cache"])
        })
        let expect = expectation(description: "Completion block called")
        Wildlink.shared.refreshDeviceToken { succeeded, deviceToken, deviceKey, deviceId in
            XCTAssertEqual(succeeded, false)
            XCTAssertEqual(deviceToken, nil)
            XCTAssertEqual(deviceKey, nil)
            XCTAssertEqual(deviceId, nil)
            expect.fulfill()
        }
        wait(for: [expect], timeout: 3.0)
    }

    func testParseHeadersFromResponse() {
        XCTAssertFalse(tokenReceived)
        Wildlink.shared.parseHeaders(from: nil)
        XCTAssertFalse(tokenReceived)
        Wildlink.shared.parseHeaders(from: HTTPURLResponse(url: URL(string: "https://google.com")!, statusCode: 200, httpVersion: nil, headerFields: ["x-wf-devicetoken": "abcdef123456"]))
        XCTAssertTrue(tokenReceived)
    }
    
    func testUpdateId() {
        Wildlink.shared.update(id: 123456)
        XCTAssertTrue(idReceived)
    }
    
    func testUpdateToken() {
        Wildlink.shared.update(token: "123456")
        XCTAssertTrue(tokenReceived)
    }
    
    func testUpdateKey() {
        Wildlink.shared.update(key: "123456")
        XCTAssertTrue(keyReceived)
    }
    
    func testGenerateWildlinkError() {
        let error = Wildlink.shared.generateWildlinkError(from: nil, with: WildlinkTestError.generic)
        XCTAssertEqual(error.errorData.keys.count, 0)
        switch error.kind {
        case .invalidURL:
            XCTFail()
        case .invalidResponse:
            XCTFail()
        case .serverError(_):
            print("Valid")
        }
        
        let data = """
{"WildlinkError": "Invalid auth header"}
""".data(using: .utf8)!
        let error2 = Wildlink.shared.generateWildlinkError(from: data, with: WildlinkTestError.generic)
        XCTAssertEqual(error2.errorData.keys.count, 1)
        switch error2.kind {
        case .invalidURL:
            XCTFail()
        case .invalidResponse:
            XCTFail()
        case .serverError(_):
            print("Valid")
        }
    }
    
    func testGetSignatureKey() {
        let string = Wildlink.shared.getSignatureKey(dateString: "2021-10-05T10:29:45Z", deviceToken: "abcdef123456", senderToken: nil)
        XCTAssertEqual(string, "43ff23143b681aa5c9384ef992b108ccbf4cfbc3c4f40bfe47a45d85eae9356d")
        let string2 = Wildlink.shared.getSignatureKey(dateString: "2021-10-05T10:29:45Z", deviceToken: "abcdef123456", senderToken: "xyz")
        XCTAssertEqual(string2, "00f744e368f4a265427713c3cf2d4a38e85d1aec724f61639fd74de479875949")
        let string3 = Wildlink.shared.getSignatureKey(dateString: "2021-10-05T10:29:45Z", deviceToken: nil, senderToken: "xyz")
        XCTAssertEqual(string3, "1fdfbdeb38403fd573ee07d445cc7b95b6d1d732755e5743bcb4a7fd549fee3d")
    }
    
    func testGetAuthorizationString() {
        let string = Wildlink.shared.getAuthorizationString(dateString: "2021-10-05T10:29:45Z", deviceToken: "abcdef123456", senderToken: nil)
        XCTAssertEqual(string, "WFAV1 :43ff23143b681aa5c9384ef992b108ccbf4cfbc3c4f40bfe47a45d85eae9356d:abcdef123456:")
        let string2 = Wildlink.shared.getAuthorizationString(dateString: "2021-10-05T10:29:45Z", deviceToken: "abcdef123456", senderToken: "xyz")
        XCTAssertEqual(string2, "WFAV1 :00f744e368f4a265427713c3cf2d4a38e85d1aec724f61639fd74de479875949:abcdef123456:xyz")
        let string3 = Wildlink.shared.getAuthorizationString(dateString: "2021-10-05T10:29:45Z", deviceToken: nil, senderToken: "xyz")
        XCTAssertEqual(string3, "WFAV1 :1fdfbdeb38403fd573ee07d445cc7b95b6d1d732755e5743bcb4a7fd549fee3d::xyz")
    }
}
