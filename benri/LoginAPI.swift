//
//  LoginAPI.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 7/6/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import UIKit
import CryptoSwift
import Alamofire
import SwiftyJSON

class LoginAPI: NSObject {
    let apiBaseURL:String   = "https://gobbl-auth.herokuapp.com"
    let apiEndPoint:String  = "/auth/login/facebook"
    var keyChainService:KeyChainService = KeyChainService()
    
    var key:[UInt8]!
    
    override init(){
        super.init()
        let path = NSBundle.mainBundle().pathForResource("APISetting", ofType: "plist")!
        let dict = NSDictionary(contentsOfFile: path) as! Dictionary<String, AnyObject>
        let gobblKey = dict["Gobbl"] as! String
        self.key = stringToByte(gobblKey)
        
    }
    
    func loginByFacebook(accessToken: String, fid: String, email: String, successCallback:(json:AnyObject?)->Void, errorCallback:()->Void){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        var userDefault = NSUserDefaults.standardUserDefaults()
        let parameters = [
            "access_token" : accessToken,
            "email" : email,
            "id" : fid
        ]
        Alamofire.request(.POST, apiBaseURL + apiEndPoint, parameters: parameters, encoding: .JSON)
            .responseJSON{ (req, res, json, error) in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if(error != nil) {
                    NSLog("Error: \(error)")
                    println(req)
                    println(res)
                    errorCallback()
                }
                else {
                    if let json:AnyObject = json {
                        let tokenJSON = JSON(json)
                        if let serverToken = tokenJSON["token"].rawString() {
                            self.keyChainService.saveToken(.ServerToken, token: serverToken)
                        }
                    }
                   
                    successCallback(json: json)
                }
        }

    }
    
    func stringToByte(str:String) -> [UInt8] {
        var byteArray = [UInt8]()
        for char in str.utf8{
            byteArray.append(char)
        }
        return byteArray
    }
    
}
