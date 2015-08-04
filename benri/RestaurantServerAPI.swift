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
    let batchApiEndPoint:String = "/batch/restaurants"
    var token:String!
    
    init(){
        var keyChainService = KeyChainService()
        token = keyChainService.loadToken(.ServerToken)
    }
    func getRestaurantAll(limit:Int, successCallback:(json:AnyObject?)->Void, errorCallback:()->Void){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        Alamofire.request(.GET, apiBaseURL + apiEndPoint, parameters:nil, encoding: .URL)
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
            "limit": String(limit),
            "token": self.token
        ]
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
    func getRestaurantByIDs(ids:[String], successCallback:(json:AnyObject?)->Void, errorCallback:()->Void){
        
        let params:[String:AnyObject] = [
            "ids"  : ids,
            "token": self.token
        ]
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        Alamofire.request(.GET, apiBaseURL + batchApiEndPoint, parameters: params, encoding: .URL)
            .responseJSON{ (req, res, json, error) in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if(error != nil) {
                    NSLog("Error: \(error)")
                    println(req)
                    println(res)
                    errorCallback()
                }
                else {
                    println(req)
                    successCallback(json: json)
                }
        }
    }
}