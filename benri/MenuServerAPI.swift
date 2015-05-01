//
//  MenuServerAPI.swift
//  benri
//
//  Created by Kittikorn Ariyasuk on 5/1/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class MenuSVAPI {
    
    let apiBaseURL:String   = "http://snakebite.herokuapp.com"
    let apiEndPoint:String  = "/menus"
    
    init(){
        
    }
    func getMenuAll(limit:Int, successCallback:(json:AnyObject?)->Void, errorCallback:()->Void){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let my_response = Alamofire.request(.GET, apiBaseURL + apiEndPoint)
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
    
    func getMenu(start:Int, limit:Int, successCallback:(json:AnyObject?)->Void, errorCallback:()->Void){
        
        let params = [
            "start": String(start),
            "limit": String(limit)
        ]
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let my_response = Alamofire.request(.GET, apiBaseURL + apiEndPoint, parameters: params)
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
    
    func getMenuByTags(tags:String, start:Int, limit:Int, successCallback:(json:AnyObject?)->Void, errorCallback:()->Void){
        
        let params = [
            "tags"  : tags,
            "start": String(start),
            "limit": String(limit)
        ]
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let my_response = Alamofire.request(.GET, apiBaseURL + apiEndPoint, parameters: params)
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