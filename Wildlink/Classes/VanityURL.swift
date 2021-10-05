//
//  VanityURL.swift
//  Wildlink
//
//  Created by Kyle Kurz - Wildfire on 10/7/21.
//

import Foundation

public struct VanityURL: Codable {
    public let originalURL: URL
    public let vanityURL: URL
    
    enum CodingKeys: String, CodingKey {
        case originalURL = "OriginalURL"
        case vanityURL = "VanityURL"
    }
}
