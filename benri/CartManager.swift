//
//  CartManager.swift
//  adam
//
//  Created by ariyasuk-k on 7/10/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import UIKit

class CartManager: NSObject {
    
    var orders:NSMutableDictionary!
    
    override init() {
    
    }
    
    func clearOrder() {
        orders.removeAllObjects()
    }
    
    func getOrderByMenuID(menuID:String) -> Order? {
        if let order:Order = orders.objectForKey(menuID) as? Order{
            return order
        }
        return nil
    }
    
    
    
    class var sharedInstance : ImageCache {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : ImageCache? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = ImageCache()
        }
        return Static.instance!
    }

}
