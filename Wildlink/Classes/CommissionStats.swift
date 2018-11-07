//
//  CommissionStats.swift
//  Wildlink
//
//  Copyright © 2019 Wildfire, Systems. All rights reserved.
//

import Foundation

public struct CommissionStats {
    //Total commissions for user's device(s) not yet confirmed by networks.
    public let pendingAmount: String
    //Total commissions for user's device(s) confirmed by networks, but not yet paid by Wildfire.
    public let readyAmount: String
    //Total commissions for user's device(s) already paid by Wildfire.
    public let paidAmount: String
    
    //create a dictionary from the struct. Note that the dictionary keys are PascalCasing to match
    //the data returned from the Wildfire servers.
    public var dictionary: [String: Any] {
        return [
            "PendingAmount": pendingAmount,
            "ReadyAmount": readyAmount,
            "PaidAmount": paidAmount
        ]
    }
}

extension CommissionStats : JSONSerializable {
    public init?(dictionary: [String : Any]) {
        guard let pendingAmount = dictionary["PendingAmount"] as? String,
            let readyAmount = dictionary["ReadyAmount"] as? String,
            let paidAmount = dictionary["PaidAmount"] as? String else {
                return nil
        }
        
        self.init(pendingAmount: pendingAmount, readyAmount: readyAmount, paidAmount: paidAmount)
    }
}
