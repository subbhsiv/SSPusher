//
//  SSIdentityAndTrust.swift
//  SSPusher
//
//  Created by Subbhaash Siva on 8/7/17.
//  Copyright © 2017 Subbhaash. All rights reserved.
//

import Foundation

public class SSIdentityAndTrust: NSObject {
    public var identityRef:SecIdentity!
    public var trust: SecTrust!
    public var certArray: AnyObject!
    
    public init(identityRef: SecIdentity, trust: SecTrust, certArray: AnyObject) {
        self.identityRef    = identityRef
        self.trust          = trust
        self.certArray      = certArray
    }
}
