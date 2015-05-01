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
    
    func setMenuImage(menuImage:UIImage) {
        self.imgIsSet = true
        self.imgUI = menuImage
    }
    
    func getMenuImage() -> UIImage {
        return self.imgUI
    }
}