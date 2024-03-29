//
//  StringEx.swift
//  Wildlink
//
//  Created by Raymond Kim on 8/24/17.
//  Copyright © 2017 Wildfire. All rights reserved.
//

import Foundation
import CommonCrypto

extension String {
    func digestHMac256(key: String) -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = self.lengthOfBytes(using: String.Encoding.utf8)
        
        let digestLen = Int(CC_SHA256_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        result.initialize(repeating: 0, count: digestLen)
        
        let keyStr = key.cString(using: String.Encoding.utf8)
        let keyLen = key.lengthOfBytes(using: String.Encoding.utf8)
        
        let algorithm = CCHmacAlgorithm(kCCHmacAlgSHA256)
        
        CCHmac(algorithm, keyStr!, keyLen, str!, strLen, result)
        
        let digest = String.stringFrom(result, with: digestLen)
        
        result.deallocate()
        
        return digest

    }
    
    static func stringFrom(_ ptr: UnsafeMutablePointer<CUnsignedChar>, with length: Int) -> String {
        let hash = NSMutableString()
        for i in 0..<length {
            hash.appendFormat("%02x", ptr[i])
        }
        return String(hash)
    }
}

