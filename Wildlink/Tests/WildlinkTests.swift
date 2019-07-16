//
//  WildlinkTests.swift
//  Wildlink-Unit-Tests
//
//  Created by Kyle Kurz on 7/15/19.
//

import XCTest
import Wildlink

class WildlinkTests: XCTestCase {
    func testInitializeSDKWithNilDeviceInfo() {
        //initialize wildlink
        Wildlink.shared.initialize(appId: "APP_ID", appSecret: "APP_SECRET", wildlinkDeviceToken: nil, wildlinkDeviceKey: nil)
    }
    
    func testInitializeSDKWithDeviceInfo() {
        //initialize wildlink
        Wildlink.shared.initialize(appId: "APP_ID", appSecret: "APP_SECRET", wildlinkDeviceToken: "TOKEN", wildlinkDeviceKey: "KEY")
    }
}
