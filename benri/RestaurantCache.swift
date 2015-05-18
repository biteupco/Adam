//
//  RestaurantCache.swift
//  benri
//
//  Created by ariyasuk-k on 5/18/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import Foundation

class RestaurantCache: NSObject {
    
    private var resCache = NSCache()
    
    override init() {
        
    }
    
    func clearData() {
        resCache.removeAllObjects()
    }
    
    func loadRestaurant(restaurantID:String) -> Restaurant? {
        if let restaurant: AnyObject = resCache.objectForKey(restaurantID) {
            return restaurant as? Restaurant
        } else {
            return nil
        }
    }
    
    func cacheRestaurant(restaurantID:String?, restaurant:Restaurant) {
        if let resID = restaurantID {
            resCache.setObject(restaurant, forKey: resID)
        }
    }
    
    class var sharedInstance : RestaurantCache {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : RestaurantCache? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = RestaurantCache()
        }
        return Static.instance!
    }
}