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
        
        let output = "[INFO.SDK] \(message)"
        print(output)
    }

    class func error(_ message: String) {
        
        let output = "[ERROR.SDK] \(message)"
        print(output)
    }

}
