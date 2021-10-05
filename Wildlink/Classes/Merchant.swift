//
//  Merchant.swift
//  Wildlink
//
//  Copyright © 2019 Wildfire, Systems. All rights reserved.
//

import Foundation

public struct Merchant: Codable {
    public let id: Int
    public let name: String
    public let disabled: Bool
    public let featured: Bool
    public let shortCode: String
    public let shortURL: URL
    public let images: [Image]
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case name = "Name"
        case disabled = "Disabled"
        case featured = "Featured"
        case shortCode = "ShortCode"
        case shortURL = "ShortURL"
        case images = "Images"
    }
}

public struct MerchantList: Codable {
    public let merchants: [Merchant]
    
    enum CodingKeys: String, CodingKey {
        case merchants = "Merchants"
    }
}
