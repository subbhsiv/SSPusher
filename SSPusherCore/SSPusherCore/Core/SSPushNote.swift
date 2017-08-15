//
//  SSPushNote.swift
//  SSPusher
//
//  Created by Subbhaash Siva on 8/6/17.
//  Copyright © 2017 Subbhaash. All rights reserved.
//

import Foundation

public class SSPushNote: NSObject, NSCoding {
    public var body: [String: AnyObject] = [:]
    public var deviceToken: String = ""
    public var header: [String: String] = [:]
    
    private let bodyKey        = "body"
    private let deviceTokenKey = "deviceToken"
    private let headerKey      = "header"
    
    public override init() {}
    
    public required init(coder aDecoder: NSCoder) {
        body        = (aDecoder.decodeObject(forKey: bodyKey) as?  [String : AnyObject])!
        header      = (aDecoder.decodeObject(forKey: headerKey) as?  [String : String])!
        deviceToken = (aDecoder.decodeObject(forKey: deviceTokenKey) as? String)!
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(body, forKey: bodyKey)
        aCoder.encode(header, forKey: headerKey)
        aCoder.encode(deviceToken, forKey: deviceTokenKey)
    }
}
