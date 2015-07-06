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
        
        Alamofire.request(.GET, apiBaseURL + apiEndPoint, parameters: nil, encoding: .URL)
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
    
    func getMenu(location:[CGFloat]?, start:Int, limit:Int, successCallback:(json:AnyObject?)->Void, errorCallback:()->Void){
        
        var params:[String:AnyObject] = [
            "start": String(start),
            "limit": String(limit)
        ]
        if let location = location {
            params["geolocation"] = location
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        Alamofire.request(.GET, apiBaseURL + apiEndPoint, parameters: params, encoding: .URL)
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
    
    func getMenuByTags(tags:String, location:[CGFloat]?,start:Int, limit:Int, successCallback:(json:AnyObject?)->Void, errorCallback:()->Void){
        
        var params:[String:AnyObject] = [
            "tags"  : tags,
            "start": String(start),
            "limit": String(limit)
        ]
        if let location = location {
            params["geolocation"] = location
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        Alamofire.request(.GET, apiBaseURL + apiEndPoint, parameters: params, encoding: .URL)
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