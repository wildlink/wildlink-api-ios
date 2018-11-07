//
//  Merchant.swift
//  Wildlink
//
//  Copyright © 2019 Wildfire, Systems. All rights reserved.
//

import Foundation

public struct Merchant {
    public let id: Int
    public let name: String
    public let disabled: Bool
    public let featured: Bool
    public let shortCode: String
    public let shortURL: URL
    public let images: [String]
    
    //create a dictionary from the struct. Note that the dictionary keys are PascalCasing to match
    //the data returned from the Wildfire servers.
    public var dictionary: [String: Any] {
        return [
            "ID": id,
            "Name": name,
            "Disabled": disabled,
            "Featured": featured,
            "ShortCode": shortCode,
            "ShortURL": shortURL.absoluteString,
            "Images": images
        ]
    }
}

extension Merchant : JSONSerializable {
    public init?(dictionary: [String : Any]) {
        guard let id = dictionary["ID"] as? Int,
            let name = dictionary["Name"] as? String,
            let disabled = dictionary["Disabled"] as? Bool,
            let featured = dictionary["Featured"] as? Bool,
            let shortCode = dictionary["ShortCode"] as? String,
            let shortUrlString = dictionary["ShortURL"] as? String,
            let shortURL = URL(string: shortUrlString),
            let images = dictionary["Images"] as? [String] else {
                return nil
        }
        
        self.init(id: id, name: name, disabled: disabled, featured: featured, shortCode: shortCode, shortURL: shortURL, images: images)
    }
}
