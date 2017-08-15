//
//  SSDataManager.swift
//  SSPusher
//
//  Created by Subbhaash Siva on 8/7/17.
//  Copyright © 2017 Subbhaash. All rights reserved.
//

import Foundation

public class SSDataManager: NSObject {
    
    private let pushNotesKey                = "SSPusher_PushNotes"
    private let certificatesKey             = "SSPusher_Certificates"
    private let selectedCertificateNameKey  = "SSPusher_SelectedCertificateNameKey"
    private let selectedEnvironmentKey      = "SSPusher_SelectedEnvironmentKey"

    
    public static let shared = SSDataManager()
    
    private var sentPushNotes: [SSPushNote] = []
    public var savedCertificates: [SSCertificate] = []
    public var lastSelectedEnvironment: PushNotificationEnvironment = .sandbox {
        didSet {
            saveLastSavedEnvironment()
        }
    }
    
    public var lastSelectedCertificateName: String? {
        didSet {
            saveLastSelectedCertificateName()
        }
    }
    
    public var recentlySentPushNote: SSPushNote? {
        return sentPushNotes.last
    }
    
    public var lastSelectedCertificate: SSCertificate? {
        if let lastSelectedCertificateName = lastSelectedCertificateName {
            for certificate in savedCertificates {
                if certificate.displayName == lastSelectedCertificateName {
                    return certificate
                }
            }
        }
        
        return nil
    }
    
    //MARK: Lifecycle Methods
    
    private override init() {
        super.init()
        loadDataFromUserDefaults()
    }
    
    //MARK: Public Methods
    
    public func savePushNote(_ note: SSPushNote) {
        sentPushNotes.append(note)
        savePushNotes()
    }
    
    public func saveCertificate(_ certificate: SSCertificate) {
        savedCertificates.append(certificate)
        saveCertificates()
    }
    
    public func loadDataFromUserDefaults() {
        //Load push notes
        if let pushNotesData = UserDefaults.standard.object(forKey: pushNotesKey) as? Data {
            sentPushNotes = (NSKeyedUnarchiver.unarchiveObject(with: pushNotesData) as? [SSPushNote]) ?? []
        }
        
        //Load certificates
        if let certificateData = UserDefaults.standard.object(forKey: certificatesKey) as? Data {
            savedCertificates = (NSKeyedUnarchiver.unarchiveObject(with: certificateData) as? [SSCertificate]) ?? []
        }
        
        //Load selected environment
        let savedSelectedEnvironment = UserDefaults.standard.integer(forKey: selectedEnvironmentKey)
        lastSelectedEnvironment = PushNotificationEnvironment(rawValue: savedSelectedEnvironment) ?? .sandbox
        
        //Load selected certificate
        lastSelectedCertificateName = UserDefaults.standard.string(forKey: selectedCertificateNameKey)
    }
    
    public func saveData() {
        saveLastSavedEnvironment()
        saveLastSelectedCertificateName()
        saveCertificates()
        savePushNotes()
    }
    
    //MARK: Private Methods
    
    private func saveLastSavedEnvironment() {
        UserDefaults.standard.set(lastSelectedEnvironment.rawValue, forKey: selectedEnvironmentKey)
        UserDefaults.standard.synchronize()
    }
    
    private func saveLastSelectedCertificateName() {
        UserDefaults.standard.set(lastSelectedCertificateName, forKey: selectedCertificateNameKey)
        UserDefaults.standard.synchronize()
    }
    
    private func savePushNotes() {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: sentPushNotes)
        UserDefaults.standard.set(encodedData, forKey: pushNotesKey)
        UserDefaults.standard.synchronize()
    }
    
    private func saveCertificates() {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: savedCertificates)
        UserDefaults.standard.set(encodedData, forKey: certificatesKey)
        UserDefaults.standard.synchronize()
    }
}
