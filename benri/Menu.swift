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
    var _storeName: String  = "res_name"
    var storeName: String {
        get {
            return _storeName
        }
        set(newStoreName) {
            if count(newStoreName) > 0 {
                _storeName = newStoreName
            }
            else {
                println("Error Rstaurantname can't be empty")
            }
        }
    }
    
    var _imgURL: NSURL      = NSURL(string: "http://someurl.com")!
    var imgURL:NSURL {
        get {
            return _imgURL
        }
        set(newURL) {
            _imgURL = newURL
        }
    }
    
    var _imgUI: UIImage     = UIImage(named: "nilImage")!
    var imgUI:UIImage {
        get {
            return _imgUI
        }
        set(newImage) {
            _imgUI = newImage
        }
    }
    
    var _imgIsSet:Bool      = false
    var imgIsSet:Bool {
        get {
            return _imgIsSet
        }
        set(isSet){
            _imgIsSet = isSet
        }
    }
    
    var _distanceVal:Double  = 1.0
    var distanceVal:Double {
        get {
            return _distanceVal
        }
        set(newDistance) {
            _distanceVal = newDistance
        }
    }
    
    var pointVal:Int        = 1
    var price:Float         = 800
    var address:String      = "roppongi"
    var latitude:Double     = 0.0
    var longitude:Double    = 0.0
    var currency:String     = "JPY"
    var currencySign:String = "¥"
    var tags:NSMutableArray = []
    var menuID:String       = "1234ID"
    var storeID:String      = "1234ID"
    
    init() {
    
    }
    
    init(menuName: String, storeName: String, imgURL: NSURL, distanceVal: Double, pointVal: Int, price: Float, address: String, latitude:Double, longitude:Double) {
        self.menuName       = menuName
        self.storeName      = storeName
        self.imgURL         = imgURL
        self.distanceVal    = distanceVal
        self.pointVal       = pointVal
        self.price          = price
        self.address        = address
        self.latitude       = latitude
        self.longitude      = longitude
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
        if let storeID:String = itemJSON["restaurant"]["$id"]["$oid"].string {
            self.storeID = storeID
        }
    }
    /*
    func setMenuName(menuName:String) {
        self.menuName = menuName
    }
    
    func getMenuName() -> String {
        return self.menuName
    }
    
    func setStoreName(storeName:String) {
        self.storeName = storeName
    }
    
    func getStoreName()->String {
        return self.storeName
    }
    
    func setImgURL(imgURL:NSURL) {
        self.imgURL = imgURL
    }
    
    func getImgURL()->NSURL {
        return self.imgURL
    }
    
    func setDistanceVal(distanceVal:Double) {
        self.distanceVal = distanceVal
    }
    
    func getDistanceVal()->Double {
        return self.distanceVal
    }
    
    func setPointVal(pointVal:Int) {
        self.pointVal = pointVal
    }
    
    func getPointVal()->Int{
        return self.pointVal
    }
    
    func setPrice(price:Float){
        self.price = price
    }
    
    func getPrice()->Float {
        return self.price
    }
    
    func setAddress(address:String) {
        self.address = address
    }
    
    func getAddress()->String {
        return self.address
    }
    
    func setLatitude(latitude:Double){
        self.latitude = latitude
    }
    
    func getLatitude()->Double {
        return self.latitude
    }
    
    func setLongitude(longitude:Double) {
        self.longitude = longitude
    }
    
    func getLongitude()-> Double {
        return self.longitude
    }
    
    func setMenuImage(menuImage:UIImage) {
        self.imgIsSet = true
        self.imgUI = menuImage
    }
    
    func getMenuImage() -> UIImage {
        return self.imgUI
    }
    
    func setStoreID(storeID:String) {
        self.storeID = storeID
    }
    
    func getStoreID()->String {
        return self.storeID
    }*/
}