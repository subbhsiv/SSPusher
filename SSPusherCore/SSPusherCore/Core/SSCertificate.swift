//
//  SSCertificate.swift
//  SSPusher
//
//  Created by Subbhaash Siva on 8/7/17.
//  Copyright © 2017 Subbhaash. All rights reserved.
//

import Foundation

public class SSCertificate: NSObject, NSCoding {
    public var displayName: String!
    public var passPhrase: String!
    public var data: Data!
    
    private let displayNameKey = "displayName"
    private let passPhraseKey = "passPhrase"
    private let dataKey = "data"
    
    public override init() {}
    
    public required init(coder aDecoder: NSCoder) {
        displayName = aDecoder.decodeObject(forKey: displayNameKey) as? String
        passPhrase = aDecoder.decodeObject(forKey: passPhraseKey) as? String
        data = aDecoder.decodeObject(forKey: dataKey) as? Data
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(displayName, forKey: displayNameKey)
        aCoder.encode(passPhrase, forKey: passPhraseKey)
        aCoder.encode(data, forKey: dataKey)
    }
}
