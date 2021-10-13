//
//  CommissionDetails.swift
//  Wildlink
//
//  Copyright © 2019 Wildfire, Systems. All rights reserved.
//

import Foundation

public enum CommissionStatus: String, Codable {
    case ready = "READY"
    case pending = "PENDING"
    case paid = "PAID"
}

public struct CommissionDetail: Codable {
    //identifier for this detail object
    public let id: Int
    //identifiers for any associated commission detail objects
    public let commissionIds: [Int]
    //the date this commission occurred
    public let date: Date
    //how much commission was earned
    public let amount: String
    //current status, see CommissionStatus enum for possible options
    public let status: CommissionStatus
    //the merchant where this commission was earned
    public let merchant: String
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case commissionIds = "CommissionIDs"
        case date = "Date"
        case amount = "Amount"
        case status = "Status"
        case merchant = "Merchant"
    }
}
