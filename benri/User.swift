//
//  User.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 6/21/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import Foundation

class User:NSObject {
    
    private var email: String!
    private var facebookID: String!
    private var fullName: String!
    private var profileImageURL: String!
    private var isUserSet:Bool!
    
    override init() {
        self.isUserSet = false
    }
    
    func setUpUserData(email:String, facebookID:String, fullName:String, profileImageURL:String) {
        self.email = email
        self.facebookID = facebookID
        self.fullName = fullName
        self.profileImageURL = profileImageURL
         self.isUserSet = true
    }
    
    func clearData() {
        self.email = nil
        self.facebookID = nil
        self.fullName = nil
        self.profileImageURL = nil
        self.isUserSet = false
    }
    
    class var sharedInstance : User {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : User? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = User()
        }
        return Static.instance!
    }

}