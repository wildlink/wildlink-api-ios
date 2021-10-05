//
//  Image.swift
//  Wildlink
//
//  Created by Kyle Kurz - Wildfire on 10/5/21.
//

import Foundation

public enum ImageKind: String, Codable {
    case general = "GENERAL"
    case featured = "FEATURED"
    case logo = "LOGO"
}

public struct Image: Codable {
    public let id: UInt64
    public let kind: ImageKind
    public let ordinal: Int64
    public let imageId: UInt64
    public let url: URL
    public let width: UInt64
    public let height: UInt64
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case kind = "Kind"
        case ordinal = "Ordinal"
        case imageId = "ImageID"
        case url = "URL"
        case width = "Width"
        case height = "Height"
    }
}
