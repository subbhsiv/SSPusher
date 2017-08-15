//
//  Array+Utility.swift
//  SSPusher
//
//  Created by Subbhaash Siva on 8/6/17.
//  Copyright © 2017 Subbhaash. All rights reserved.
//

import Foundation

public extension Array {
    public func isLastItem(_ item: AnyObject) -> Bool {
        if let item = item as? _OptionalNilComparisonType {
            return (item == last)
        }
        
        return false
    }
}
