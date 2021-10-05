//
//  CommissionStats.swift
//  Wildlink
//
//  Copyright © 2019 Wildfire, Systems. All rights reserved.
//

import Foundation

public struct CommissionStats: Codable {
    //Total commissions for user's device(s) not yet confirmed by networks.
    public let pendingAmount: String
    //Total commissions for user's device(s) confirmed by networks, but not yet paid by Wildfire.
    public let readyAmount: String
    //Total commissions for user's device(s) already paid by Wildfire.
    public let paidAmount: String
    
    enum CodingKeys: String, CodingKey {
        case pendingAmount = "PendingAmount"
        case readyAmount = "ReadyAmount"
        case paidAmount = "PaidAmount"
    }
}
