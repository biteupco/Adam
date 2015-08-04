//
//  FilterManager.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 7/27/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import UIKit

class FilterManager: NSObject {
    var location:CLLocation
    var locality:String
    var tag:String
    
    override init() {
        location = CLLocation(latitude: 35.664122, longitude: 139.729426)
        locality = "Minato"
        tag = "Japanese"
    }
        
    class var sharedInstance : FilterManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : FilterManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = FilterManager()
        }
        return Static.instance!
    }
}
