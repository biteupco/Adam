//
//  RestaurantServerAPI.swift
//  benri
//
//  Created by ariyasuk-k on 5/15/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class RestaurantSVAPI {
    
    let apiBaseURL:String   = "http://snakebite.herokuapp.com"
    let apiEndPoint:String  = "/restaurants"
    
    init(){
        
    }
    func getRestaurantAll(limit:Int, successCallback:(json:AnyObject?)->Void, errorCallback:()->Void){
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
    
    func getRestaurantByID(id:String, limit:Int, successCallback:(json:AnyObject?)->Void, errorCallback:()->Void){
        
        let params = [
            "id"  : id,
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