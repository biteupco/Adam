//
//  LikeItemManager.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 8/9/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import UIKit

class LikeItemManager: NSObject {
    var menus:NSMutableDictionary!
    var restaurants:NSMutableDictionary!
    override init() {
        
    }
    
    func clearOrder() {
        menus.removeAllObjects()
    }
    
    func addItem(menuID:String, menu:Menu, resID:String, restaurant:Restaurant) {
        if let menu:Menu = menus.objectForKey(menuID) as? Menu{
            return
        }
        menus.setObject(menu, forKey: menuID)
        
        if let restaurant:Restaurant = restaurants.objectForKey(resID) as? Restaurant{
            return
        }
        restaurants.setObject(restaurant, forKey: resID)
    }
    
    func getItem(menuID:String, resID:String) -> (Menu?, Restaurant?) {
        if let menu:Menu = menus.objectForKey(menuID) as? Menu{
            if let restaurant:Restaurant = restaurants.objectForKey(resID) as? Restaurant {
                return (menu, restaurant)
            }
        }
        return (nil, nil)
    }
    
    
    class var sharedInstance : LikeItemManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : LikeItemManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = LikeItemManager()
        }
        return Static.instance!
    }

}
