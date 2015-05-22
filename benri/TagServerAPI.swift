//
//  TagServerAPI.swift
//  benri
//
//  Created by Kittikorn Ariyasuk on 5/1/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class TagSVAPI {
    
    let apiBaseURL:String   = "http://snakebite.herokuapp.com"
    let apiEndPoint:String  = "/tags"
    
    init(){
        
    }
    func getTags(limit:Int, successCallback:(json:AnyObject?)->Void, errorCallback:()->Void){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        Alamofire.request(.GET, apiBaseURL + apiEndPoint,parameters: ["limit": limit])
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
    }
}