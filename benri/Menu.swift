//
//  Menu.swift
//  adam
//
//  Created by ariyasuk-k on 2015/01/23.
//  Copyright (c) 2015年 Benri. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class Menu {
    var _menuName:String   = "menu_name"
    var menuName: String {
        get {
            return _menuName
        }
        set(newName) {
            if count(newName) > 0 {
               _menuName = newName
            }
            else {
                println("Error menu name can't be empty")
            }
            
        }
    }
    
    var _imgURL: NSURL = NSURL(string: "http://someurl.com")!
    var imgURL:NSURL {
        get {
            return _imgURL
        }
        set(newURL) {
            _imgURL = newURL
        }
    }
    
    var _imgUI: UIImage = UIImage(named: "nilImage")!
    var imgUI:UIImage {
        get {
            return _imgUI
        }
        set(newImage) {
            _imgUI = newImage
        }
    }
    
    var _imgIsSet:Bool = false
    var imgIsSet:Bool {
        get {
            return _imgIsSet
        }
        set(isSet){
            _imgIsSet = isSet
        }
    }
    
    var pointVal:Int = 0
    
    var _price:Float = 0
    var price:Float {
        get {
            return _price
        }
        set(newPrice) {
            _price = newPrice
        }
    }
    var _menuID:String = "1234ID"
    var menuID:String {
        get {
            return _menuID
        }
        set(newMenuID) {
            if count(newMenuID) > 0 {
                _menuID = newMenuID
            }
        }
    }
    var _restaurantID:String = "1234ID"
    var restaurantID:String {
        get {
            return _restaurantID
        }
        set(newrestaurantID) {
            _restaurantID = newrestaurantID
        }
    }
    
    var _ratingCount:Int = 0
    var ratingCount:Int {
        get {
            return _ratingCount
        }
        set(newRatingCount) {
            _ratingCount = newRatingCount
        }
    }
    
    var _ratingTotal:Int = 1
    var ratingTotal:Int {
        get {
            return _ratingTotal
        }
        set(newRatingTotal) {
            _ratingTotal = newRatingTotal
        }
    }
    
    var currency:String     = "JPY"
    var currencySign:String = "¥"
    var tags:NSMutableArray = []
    
    init() {
    
    }
    
    init(menuName: String, menuID: String, restaurantID: String, imgURL: NSURL, pointVal: Int, price: Float) {
        self.menuName       = menuName
        self.menuID         = menuID
        self.restaurantID   = restaurantID
        self.imgURL         = imgURL
        self.pointVal       = pointVal
        self.price          = price
    }
    
    func initByJSON(itemJSON:JSON) {
        /**** Menu ID ****/
        if let menuID:String = itemJSON["_id"]["$oid"].rawString() {
            self.menuID = menuID
        }
        
        /**** Menu Name ****/
        if let menuName:String = itemJSON["name"].rawString() {
            self.menuName = menuName
        }
        
        /**** Price ****/
        if let price:Float = itemJSON["price"].float {
            self.price = price
        }
        
        /**** currency ****/
        if let currency:String = itemJSON["currency"].string {
            self.currency = currency
        }
        
        /**** Image URL ****/
        if let imgURLString:String = itemJSON["images"][0].string {
            var imgURLSafe = imgURLString.stringByReplacingOccurrencesOfString("\"", withString: "", options:  NSStringCompareOptions.LiteralSearch, range: nil)
            if let imgURL = NSURL(string: imgURLSafe) {
                self.imgURL = imgURL
            }
        }
        
        /**** Tags ****/
        for (index:String, tagsJSON: JSON) in itemJSON["tags"] {
            if let tag = tagsJSON.string {
                self.tags.addObject(tag)
            }
        }
        
        /**** Yum ****/
        if let pointVal:Int = itemJSON["yums"].int {
            self.pointVal = pointVal
        }
        
        /**** Restuarant ID ****/
        if let restaurantID:String = itemJSON["restaurant"]["$id"]["$oid"].string {
            self.restaurantID = restaurantID
        }
        
        /**** Rating count ****/
        if let ratingCount:Int = itemJSON["ratingCount"].int {
            self.ratingCount = ratingCount
        }
        
        /**** Rating total ****/
        if let ratingTotal:Int = itemJSON["ratingTotal"].int {
            self.ratingTotal = ratingTotal
        }
    }
}