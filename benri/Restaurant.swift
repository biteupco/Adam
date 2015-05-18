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
    
    var _name:String
    var name:String {
        get {
            return _name
        }
        
        set(newName) {
            if(count(newName) > 0){
                _name = newName
            }
            else {
                println("Error Restuarant name can't be empty")
            }
        }
    }
    var _id:String
    var id:String {
        get {
            return _id
        }
        
        set(newID) {
            if(count(newID) > 0){
                _id = newID
            }
            else {
                println("Error Restuarant ID can't be empty")
            }
        }
    }
    var _location:CLLocation
    var location:CLLocation {
        get {
            return _location
        }
        set(newLocation) {
            _location = newLocation
        }
    }
    
    var _address:String
    var address:String {
        get {
            return _address
        }
        set(newAddress) {
            if(count(newAddress) > 0) {
                _address = newAddress
            }
            else {
                println("Error Address can't be Empty")
            }
        }
    }
    
    var _email:String
    var email:String {
        get {
            return _email
        }
        set(newEmail) {
            _email = newEmail
        }
        
    }
    
    var _description:String
    var description:String {
        get {
            return _description
        }
        set(newDescription) {
            _description = newDescription
        }
    }
    
    init() {
        _name = ""
        _id = ""
        _location = CLLocation(latitude: 35.6895, longitude: 139.6917)
        _address = ""
        _email = ""
        _description = ""
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
}