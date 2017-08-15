//
//  SSPusherViewController.swift
//  SSPusher
//
//  Created by Subbhaash Siva on 8/6/17.
//  Copyright © 2017 Subbhaash. All rights reserved.
//

import Cocoa
import SSPusherCore

class SSPusherViewController: NSViewController {
    //MARK: Constants
    private let deviceTokenKey                 = "SSPusher_deviceTokenKey"
    
    private let invalidDictionaryErrorMessage   = "Error: Invalid JSON Dictionary"
    
    //MARK: IBOutlets
    @IBOutlet weak var mainStackView: NSStackView!
    @IBOutlet weak var deviceTokenTextView: NSTextView!
    @IBOutlet weak var bodyTextView: NSTextView!
    @IBOutlet weak var headerTextView: NSTextView!

    @IBOutlet weak var bodyErrorMessageLabel: NSTextField!
    @IBOutlet weak var headerErrorMessageLabel: NSTextField!
    
    @IBOutlet weak var resultLabel: NSTextField!
    @IBOutlet weak var selectCertificatePopupButton: NSPopUpButton!
    
    @IBOutlet weak var productionEnvironmentButton: NSButton!
    @IBOutlet weak var pushButton: NSButton!
    
    @IBOutlet weak var spinner: NSProgressIndicator!
    //MARK: Properties
    private var savedCertificates: [SSCertificate] {
        return SSDataManager.shared.savedCertificates
    }
    
    private var deviceToken: String?
    private var selectedCertificateIndex: Int  = 0
    private var selectedEnvironment: PushNotificationEnvironment {
        get {
            return SSDataManager.shared.lastSelectedEnvironment
        }
        set {
            SSDataManager.shared.lastSelectedEnvironment = newValue
        }
    }
    
    private var header: String? {
        didSet {
            if let header = header, header.isNotEmpty {
                headerTextView.string = header
                
                if isValidHeader {
                    headerErrorMessageLabel.stringValue = ""
                }
                else {
                    headerErrorMessageLabel.stringValue = invalidDictionaryErrorMessage
                }
            }
            else {
                headerErrorMessageLabel.stringValue = ""
            }
        }
    }
    
    private var body: String? {
        didSet {
            if let body = body, body.isNotEmpty {
                bodyTextView.string = body
                
                if isValidBody {
                    bodyErrorMessageLabel.stringValue = ""
                }
                else {
                    bodyErrorMessageLabel.stringValue = invalidDictionaryErrorMessage
                }
            }
            else {
                bodyErrorMessageLabel.stringValue = invalidDictionaryErrorMessage
            }
        }
    }
    
    private var isValidHeader: Bool {
        return (header?.isValidDictionaryWithStringKey == true)
    }
    
    private var isValidBody: Bool {
        return (body?.isValidDictionaryWithStringKey == true)
    }

    private var lastUsedCertificate: SSCertificate? {
        return SSDataManager.shared.lastSelectedCertificate
    }
    
    private var lastItemIndex: Int {
        return savedCertificates.count + 1
    }
    
    //MARK: Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Custom setup
        loadSavedDetails()
        setupInitialUI()
        
        self.headerTextView.isAutomaticQuoteSubstitutionEnabled = false
        self.deviceTokenTextView.isAutomaticQuoteSubstitutionEnabled = false
        self.bodyTextView.isAutomaticQuoteSubstitutionEnabled = false
    }
    
    //MARK: IBActions
    
    @IBAction func cerficateSelection(_ sender: NSPopUpButtonCell) {
        let selectedIndex = selectCertificatePopupButton.indexOfSelectedItem
        
        //Select Certificate
        if selectedCertificateIndex == 0 && selectedIndex == 0 {
            //Do nothing
        }
        //Import Certificate
        else if selectCertificatePopupButton.indexOfSelectedItem == lastItemIndex {
            importP12()
        }
        //Saved Certificates
        else {
            selectedCertificateIndex = selectCertificatePopupButton.indexOfSelectedItem
            let selectedCertificate = savedCertificates[selectedIndex - 1]
            SSDataManager.shared.lastSelectedCertificateName = selectedCertificate.displayName
        }
    }
    
    @IBAction func environmentButtonSelection(_ sender: NSButton) {
        if productionEnvironmentButton.state == 1 {
            selectedEnvironment = .production
        }
        else {
            selectedEnvironment = .sandbox
        }
    }
    
    @IBAction func pushButtonClicked(_ sender: NSButton) {
        deviceToken = deviceTokenTextView.string
        header = headerTextView.string
        body = bodyTextView.string
        
        let pushNote = SSPushNote()
        let isValidDeviceToken = deviceToken != nil && deviceToken!.trimmed.isNotEmpty
        let isValidCertificateSelected = (selectedCertificateIndex != 0)
        
        //Check whether data is correct
        if isValidHeader && isValidBody && isValidDeviceToken && isValidCertificateSelected {
            pushNote.header = header?.jsonValue as! [String: String]
            pushNote.body = body?.jsonValue as! [String: AnyObject]
            pushNote.deviceToken = deviceToken!.trimmed

            sendPushNote(pushNote)
        }
        //Handle Error
        else if isValidCertificateSelected == false {
            showErrorMessage("Error: Select a certificate")
        }
        else if isValidDeviceToken == false {
            showErrorMessage("Error: Invalid device token")
        }
        else if isValidHeader == false {
            showErrorMessage("Error: Invalid header")
        }
        else if isValidBody == false {
            showErrorMessage("Error: Invalid body")
        }
    }
    
    //MARK: Private methods
    private func loadSavedDetails() {
        if let recentlySentPushNote = SSDataManager.shared.recentlySentPushNote {
            body                        = recentlySentPushNote.body.jsonString
            header                      = recentlySentPushNote.header.jsonString
            deviceToken                 = recentlySentPushNote.deviceToken
        }
        
        loadSavedCertificates()
    }
    
    private func loadSavedCertificates() {
        var index = selectCertificatePopupButton.itemArray.count - 1
        let lastSelectedCertificateName = SSDataManager.shared.lastSelectedCertificateName ?? ""
        for certificate in savedCertificates {
            selectCertificatePopupButton.insertItem(withTitle: certificate.displayName, at: index)
            
            if certificate.displayName == lastSelectedCertificateName {
                selectCertificatePopupButton.selectItem(at: index)
                
                let identityContainer = SSIdentityContainer(p12Data: certificate.data as NSData, passphrase: certificate.passPhrase)
                selectedCertificateIndex = index
                SSNetworkHelper.shared.identityContainer = identityContainer
            }
            
            index += 1
        }
    }
    
    private func setupInitialUI() {
        if let deviceToken = deviceToken {
            deviceTokenTextView.string = deviceToken
        }
        else {
            deviceTokenTextView.string = ""
        }
        
        if let body = body, body.isNotEmpty {
            bodyTextView.string = body
        }
        else {
            bodyErrorMessageLabel.stringValue = ""
        }
        
        if selectedEnvironment == .production {
            productionEnvironmentButton.state = 1
        }
        
        resultLabel.stringValue = ""
    }
    
    private func sendPushNote(_ pushNote: SSPushNote) {
        pushButton.isEnabled = false

        resultLabel.textColor = .orange
        resultLabel.stringValue = "Sending..."
        
        //Send Push note
        SSNetworkHelper.shared.sendPushNote(pushNote, inEnvironment: selectedEnvironment) {[weak self] (success, error) in
            self?.pushButton.isEnabled = true
            let resultLabel = self?.resultLabel
            if success {
                resultLabel?.textColor = .green
                resultLabel?.stringValue = "Success :)"
            }
            else {
                let errorDescription = error?.description ?? ""
                self?.showErrorMessage("Failed :( . \(errorDescription)")
            }
        }
        
        SSDataManager.shared.savePushNote(pushNote)
    }
    
    private func showErrorMessage(_ message: String) {
        resultLabel?.textColor = .red
        resultLabel?.stringValue = message

    }
    
    private func importP12() {
        //Launch alert to get p12 file
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = ["p12"]
        openPanel.runModal()
        
        //If user selects file, then show passPhrase prompt
        if let url = openPanel.urls.first {
            showPasswordToImportP12AtUrl(url)
        }
            //If user cancels, then select last selected item
        else {
            selectCertificatePopupButton.select(selectCertificatePopupButton.item(at: selectedCertificateIndex))
        }
    }
    
    private func showPasswordToImportP12AtUrl(_ url: URL) {
        
        let selectedCertificatePath = url.absoluteString
        let fileName = (selectedCertificatePath as NSString).lastPathComponent
        
        let alert = NSAlert()
        alert.messageText = "Enter the passphrase for \(fileName)"
        alert.addButton(withTitle: "Ok")
        alert.addButton(withTitle: "Cancel")
        
        let passPhraseTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 20))
        passPhraseTextField.translatesAutoresizingMaskIntoConstraints = false
        alert.accessoryView = passPhraseTextField
        
        let result = alert.runModal()
        
        //If user enters passphrase, use it to decode p12 file
        if result == NSAlertFirstButtonReturn {
            let passPhrase = passPhraseTextField.stringValue
            
            do {
                
                let data = try Data(contentsOf: url)
                
                let identityContainer = SSIdentityContainer(p12Data: data as NSData, passphrase: passPhrase)
                
                if let _ = SSNetworkHelper.shared.extractIdentityFromIdentityContrainer(identityContainer) {
                    //Valid Certificate
                    SSNetworkHelper.shared.identityContainer = identityContainer

                    saveValidCertificateWithData(data, passPhrase: passPhrase, fileName: fileName)
                }
                else {
                    //Show Error
                    showErrorMessage("Wrong password while importing \(fileName)")
                    selectCertificatePopupButton.selectItem(at: selectedCertificateIndex)
                }
            }
            catch {}
        }
        else {
            //Show Error
            showErrorMessage("Need password to import \(fileName)")
            selectCertificatePopupButton.selectItem(at: selectedCertificateIndex)
        }
    }
    
    private func saveValidCertificateWithData(_ data: Data, passPhrase: String, fileName: String) {
        resultLabel.stringValue = ""
        
        //Save new certificate
        let newCertificate = SSCertificate()
        newCertificate.data = data
        newCertificate.passPhrase = passPhrase
        //Insert new item in the list
        let numberOfItems = selectCertificatePopupButton.itemArray.count
        let indexToBeInserted = numberOfItems - 1
        var suffix = 0
        
        //If two items have the same name, then add a suffix to the last element
        while true {
            var newFileName = fileName
            if suffix > 0 {
                newFileName = fileName + " (\(suffix))"
            }
            
            selectCertificatePopupButton.insertItem(withTitle: newFileName, at: indexToBeInserted)
            if selectCertificatePopupButton.itemArray.count == numberOfItems {
                suffix += 1
            }
            else {
                newCertificate.displayName = newFileName
                SSDataManager.shared.lastSelectedCertificateName = newFileName
                break
            }
        }
        
        //Save the certificate
        SSDataManager.shared.saveCertificate(newCertificate)
        
        //Select newly inserted item
        selectCertificatePopupButton.selectItem(at: indexToBeInserted)
        selectedCertificateIndex = indexToBeInserted
    }
}
