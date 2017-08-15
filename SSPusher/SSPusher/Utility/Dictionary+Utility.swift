//
//  Dictionary+Utility.swift
//  SSPusher
//
//  Created by Subbhaash Siva on 8/7/17.
//  Copyright © 2017 Subbhaash. All rights reserved.
//

import Foundation

public extension Dictionary {
    public var jsonString: String {
        if isNotEmpty {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
                if let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) {
                    return (jsonString as String)
                }
            }
            catch {}
        }
        return "{\n}"
    }
    
    public var isValidDictionaryWithStringKey: Bool {
        if isEmpty {
            return true
        }
        
        for (key, value) in self {
            if key is String {
                if value is String {
                    return true
                }
                if let value = value as? [String : Any] {
                    return value.isValidDictionaryWithStringKey
                }
                return false
            }
            return false
        }
        
        return false
    }
}
