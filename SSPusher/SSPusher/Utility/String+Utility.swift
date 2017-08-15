//
//  String+Utility.swift
//  SSPusher
//
//  Created by Subbhaash Siva on 8/6/17.
//  Copyright © 2017 Subbhaash. All rights reserved.
//

import Foundation

public extension String {
    public var isNotEmpty: Bool {
        return (isEmpty == false)
    }
    
    public var trimmed: String {
        let trimmed = (self as NSString).trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed
    }
    
    public var jsonValue: Any? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [])
            }
            catch {}
        }
        
        return nil
    }
    
    public var isValidDictionaryWithStringKey: Bool {
        if let dictionary = jsonValue as? [String : Any] {
            return dictionary.isValidDictionaryWithStringKey
        }
        
        return false
    }
}
