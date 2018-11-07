//
//  CommissionDetails.swift
//  Wildlink
//
//  Copyright © 2019 Wildfire, Systems. All rights reserved.
//

import Foundation

public enum CommissionStatus: String {
    case ready = "READY"
    case pending = "PENDING"
    case paid = "PAID"
}

public struct CommissionDetails {
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
    
    public var dictionary: [String: Any] {
        return [
            "ID": id,
            "CommissionIDs": commissionIds,
            "Date": date.utc,
            "Amount": amount,
            "Status": status,
            "Merchant": merchant
        ]
    }
}

extension CommissionDetails : JSONSerializable {
    public init?(dictionary: [String : Any]) {
        guard let id = dictionary["ID"] as? Int,
            let commissionIds = dictionary["CommissionIDs"] as? [Int],
            let dateString = dictionary["Date"] as? String,
            let date = dateString.dateFromUTC,
            let amount = dictionary["Amount"] as? String,
            let statusString = dictionary["Status"] as? String,
            let status = CommissionStatus(rawValue: statusString),
            let merchant = dictionary["Merchant"] as? String else {
                return nil
        }
        
        self.init(id: id, commissionIds: commissionIds, date: date, amount: amount, status: status, merchant: merchant)
    }
}
