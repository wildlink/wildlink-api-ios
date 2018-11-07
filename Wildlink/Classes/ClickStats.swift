//
//  ClickStats.swift
//  Wildlink
//
//  Copyright © 2019 Wildfire, Systems. All rights reserved.
//

import Foundation

public struct ClickStats {
    //Total commissions for user's device(s) not yet confirmed by networks.
    public let period: String
    //Total commissions for user's device(s) confirmed by networks, but not yet paid by Wildfire.
    public let clickDate: Date
    //Total commissions for user's device(s) already paid by Wildfire.
    public let clickCount: Int
    
    //create a dictionary from the struct. Note that the dictionary keys are PascalCasing to match
    //the data returned from the Wildfire servers.
    public var dictionary: [String: Any] {
        return [
            "Period": period,
            "ClickDate": clickDate.utc,
            "ClickCount": clickCount
        ]
    }
}

extension ClickStats : JSONSerializable {
    public init?(dictionary: [String : Any]) {
        guard let period = dictionary["Period"] as? String,
            let clickDateString = dictionary["ClickDate"] as? String,
            let clickCount = dictionary["ClickCount"] as? Int,
            let clickDate = clickDateString.dateFromUTC else {
                return nil
        }
        
        self.init(period: period, clickDate: clickDate, clickCount: clickCount)
    }
}
