//
//  Menu.swift
//  adam
//
//  Created by ariyasuk-k on 2015/01/23.
//  Copyright (c) 2015年 Benri. All rights reserved.
//

import Foundation
import UIKit

class Menu {
    var menuName: String   = "name"
    var storeName: String  = "res_name"
    var imgURL: NSURL      = NSURL(string: "http://someurl.com")!
    var imgUI: UIImage     = UIImage(named: "nilImage")!//UIImage(contentsOfFile: "nilImage")!
    var imgIsSet:Bool      = false
    
    var distanceVal:Double  = 1.0
    var pointVal:Int       = 1
    var price:Float        = 800
    var address:String     = "roppongi"
    var latitude:Double     = 0.0
    var longitude:Double    = 0.0
    
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
}