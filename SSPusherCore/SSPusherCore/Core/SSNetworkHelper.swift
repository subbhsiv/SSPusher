//
//  SSNetworkHelper.swift
//  SSPusher
//
//  Created by Subbhaash Siva on 8/6/17.
//  Copyright © 2017 Subbhaash. All rights reserved.
//

import Foundation

//Thanks Karlos
//https://stackoverflow.com/a/34080951

public enum PushNotificationEnvironment: Int {
    case sandbox
    case production
}

public class SSIdentityContainer: NSObject {
    public var p12Data: NSData
    public var passphrase: String
    
    public init(p12Data: NSData, passphrase: String) {
        self.p12Data    = p12Data
        self.passphrase = passphrase
    }
}

public class SSNetworkHelper: NSObject, URLSessionDelegate {
    
    public static let shared = SSNetworkHelper()
    
    public var identityContainer: SSIdentityContainer!
    
    private override init() {}
    
    public typealias SendPushNotificationCompletionHandler = (_ success: Bool, _ error: APNSError?) -> Void
    
    public func sendPushNote(_ note: SSPushNote, inEnvironment environment: PushNotificationEnvironment, withCompletionHandler completionHandler: @escaping SendPushNotificationCompletionHandler) {
        let request = NSMutableURLRequest(url: NSURL(string: "https://example.com:9222")! as URL)
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: note.body, options: [])
        } catch{
            request.httpBody = nil
        }
        
        request.timeoutInterval = 20.0 //(number as! NSTimeInterval)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("gzip", forHTTPHeaderField: "Accept-encoding")
        
        for (key, value) in note.header {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        var urlString = "https://api.development.push.apple.com/3/device/"
        
        
        if environment == .production {
            urlString = "https://api.push.apple.com/3/device/"
        }
        
        urlString += "\(note.deviceToken)"
        
        let configuration = URLSessionConfiguration.default

        let session = URLSession.init(configuration: configuration, delegate: self, delegateQueue: .main)
        
        let url = URL(string: urlString)!
        request.url = url
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error as? NSError {
                let apnsError = APNSError.apnsErrorFromError(error)
                completionHandler(false, apnsError)
            }
            else if let response = response as? HTTPURLResponse {
                let statusCode = response.statusCode
                
                if statusCode == 200 {
                    completionHandler(true, nil)
                }
                else {
                    completionHandler(false, APNSError(rawValue: statusCode) ?? .unknown)
                }
            }
            else {
                completionHandler(false, .unknown)
            }
        }
        task.resume()
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let identityAndTrust:SSIdentityAndTrust = extractIdentityFromIdentityContrainer(identityContainer) {
            
            let urlCredential:URLCredential = URLCredential(
                identity: identityAndTrust.identityRef,
                certificates: identityAndTrust.certArray as? [AnyObject],
                persistence: URLCredential.Persistence.forSession)
            
            completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, urlCredential)
        }
    }
    
    public func extractIdentityFromIdentityContrainer(_ identityContainer: SSIdentityContainer) -> SSIdentityAndTrust? {
        var identityAndTrust:SSIdentityAndTrust!
        var securityError:OSStatus = errSecSuccess
        
        let key : NSString = kSecImportExportPassphrase as NSString
        let options : NSDictionary = [key : identityContainer.passphrase]
        //create variable for holding security information
        //var privateKeyRef: SecKeyRef? = nil
        
        var items : CFArray?
        
        securityError = SecPKCS12Import(identityContainer.p12Data, options, &items)
        
        if securityError == errSecSuccess {
            let certItems:CFArray = items as CFArray!
            let certItemsArray:Array = certItems as Array
            let dict:AnyObject? = certItemsArray.first
            if let certEntry:Dictionary = dict as? Dictionary<String, AnyObject> {
                
                // grab the identity
                let identityPointer:AnyObject? = certEntry["identity"]
                let secIdentityRef:SecIdentity = identityPointer as! SecIdentity!
                
                // grab the trust
                let trustPointer:AnyObject? = certEntry["trust"]
                let trustRef:SecTrust = trustPointer as! SecTrust

                // grab the cert
                let chainPointer:AnyObject? = certEntry["chain"]
                identityAndTrust = SSIdentityAndTrust(identityRef: secIdentityRef, trust: trustRef, certArray:  chainPointer!)
                return identityAndTrust
            }
        }
        return nil
    }
}
