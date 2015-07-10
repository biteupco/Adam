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
    let apiBaseURL:String   = "http://snakebite.herokuapp.com"
    let apiEndPoint:String  = "/login"
    var key:[UInt8]!
    override init(){
        super.init()
        let path = NSBundle.mainBundle().pathForResource("APISetting", ofType: "plist")!
        let dict = NSDictionary(contentsOfFile: path) as! Dictionary<String, AnyObject>
        let gobblKey = dict["Gobbl"] as! String
        self.key = stringToByte(gobblKey)
        
    }
    
    func loginByFacebook(successCallback:(json:AnyObject?)->Void, errorCallback:()->Void){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let token = "TorIsHere"//FBSDKAccessToken.currentAccessToken().tokenString
        
        let encrypted = AES(key: self.key, blockMode: .CBC)!.encrypt(stringToByte(token), padding: PKCS7())!
        println("Facebook Token")
        println(encrypted)
        /*if (FBSDKAccessToken.currentAccessToken() != nil) {
            let encrptedToken = FBSDKAccessToken.currentAccessToken()
            Alamofire.request(.GET, apiBaseURL + apiEndPoint,parameters: ["token": encrptedToken], encoding: .URL)
                .responseJSON{ (req, res, json, error) in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    if(error != nil) {
                        NSLog("Error: \(error)")
                        println(req)
                        println(res)
                        errorCallback()
                    }
                    else {
                        successCallback(json: json)
                    }
            }
        }*/
    }
    
    func stringToByte(str:String) -> [UInt8] {
        var byteArray = [UInt8]()
        for char in str.utf8{
            byteArray += [char]
        }
        println(byteArray)
        return byteArray
    }
    
}
