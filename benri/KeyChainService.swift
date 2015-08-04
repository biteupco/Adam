//
//  KeyChainService.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 7/31/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import UIKit
import Security

let userAccount = "authenticatedUser"
let accessGroup = "GobblSerivice"

public enum keyChainType {
    /* Keychain for server's token*/
    case ServerToken
}

class KeyChainService: NSObject {
    // Arguments for the keychain queries
    let kSecClassValue = kSecClass as NSString
    let kSecAttrAccountValue = kSecAttrAccount as NSString
    let kSecValueDataValue = kSecValueData as NSString
    let kSecClassGenericPasswordValue = kSecClassGenericPassword as NSString
    let kSecAttrServiceValue = kSecAttrService as NSString
    let kSecMatchLimitValue = kSecMatchLimit as NSString
    let kSecReturnDataValue = kSecReturnData as NSString
    let kSecMatchLimitOneValue = kSecMatchLimitOne as NSString

    func saveToken(type:keyChainType, token: String) {
        switch type {
        case .ServerToken:
            self.save("serverToken", data: token)
        }
    }
    
    func loadToken(type:keyChainType) -> String? {
        var serviceIdentifier:String!
        switch type {
            case .ServerToken:
                serviceIdentifier = "serverToken"
            default:
                return nil
        }
    
        var token = self.load(serviceIdentifier)
        
        return token
    }
    
    private func save(service:String, data:String) {
        var dataFromString: NSData = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        
        // Instantiate a new default keychain query
        var keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, userAccount, dataFromString], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue])
        
        // Delete any existing items
        SecItemDelete(keychainQuery as CFDictionaryRef)
        
        // Add the new keychain item
        var status: OSStatus = SecItemAdd(keychainQuery as CFDictionaryRef, nil)
    }
    
    private func load(service:String) -> String? {
        // Instantiate a new default keychain query
        // Tell the query to return a result
        // Limit our results to one item
        var keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, userAccount, kCFBooleanTrue, kSecMatchLimitOneValue], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])
        
        var dataTypeRef :Unmanaged<AnyObject>?
        
        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        
        let opaque = dataTypeRef?.toOpaque()
        
        var contentsOfKeychain: String?
        
        if let op = opaque {
            let retrievedData = Unmanaged<NSData>.fromOpaque(op).takeUnretainedValue()
            
            // Convert the data retrieved from the keychain into a string
            if let contents = NSString(data: retrievedData, encoding: NSUTF8StringEncoding) {
                contentsOfKeychain = String(contents)
            }
        } else {
            println("Nothing was retrieved from the keychain. Status code \(status)")
        }
        
        return contentsOfKeychain
    }
}
