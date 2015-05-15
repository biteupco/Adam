//
//  Restaurant.swift
//  benri
//
//  Created by ariyasuk-k on 5/15/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

class Restaurant {
    
    var name:String
    var id:String
    var location:CLLocation
    var address:String
    var email:String
    var description:String
    
    init() {
        self.name = ""
        self.id = ""
        self.location = CLLocation(latitude: 35.6895, longitude: 139.6917)
        self.address = ""
        self.email = ""
        self.description = ""
    }
    
    func initByJSON(restaurantJSON:JSON){
        if let storeName:String = restaurantJSON["name"].string {
            self.name = storeName
        }
        
        if let restaurantID:String = restaurantJSON["_id"]["$oid"].string {
            self.id = restaurantID
        }
        
        if let address:String = restaurantJSON["address"].string {
            self.address = address
        }
        
        if let lat:Double = restaurantJSON["geolocation"]["lat"].double {
            if let lon:Double = restaurantJSON["geolocation"]["lon"].double {
                self.location = CLLocation(latitude: lat, longitude: lon)
            }
        }
        
        if let description:String = restaurantJSON["description"].string{
            self.description = description
        }
        
        if let email:String = restaurantJSON["email"].string {
            self.email = email
        }
    }
    
    func setID(id:String) {
        self.id = id
    }
    
    func getID()-> String {
        return self.id
    }
}