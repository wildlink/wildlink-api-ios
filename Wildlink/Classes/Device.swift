//
//  Device.swift
//  Wildlink
//
//  Created by Kyle Kurz - Wildfire on 10/5/21.
//

import Foundation

public struct Device: Codable {
    public let token: String
    public let key: String
    public let id: UInt64
    
    enum CodingKeys: String, CodingKey {
        case token = "DeviceToken"
        case key = "DeviceKey"
        case id = "DeviceID"
    }
}
