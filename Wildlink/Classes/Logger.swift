//
//  Logger.swift
//  Wildlink
//
//  Created by David on 8/28/17.
//  Copyright © 2017 Wildfire. All rights reserved.
//

import Foundation

class Logger {
    
    init() {}
    
    class func info(_ message: String) {
#if DEBUG
        let output = "[WILDLINK.INFO] \(message)"
        print(output)
#endif
    }

    class func error(_ message: String) {
#if DEBUG
        let output = "[WILDLINK.ERROR] \(message)"
        print(output)
#endif
    }

}
