//
//  LocationService.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 2/24/15.
//  Copyright (c) 2015 Benri. All rights reserved.
//

import Foundation
import CoreLocation

class LocationService: NSObject {
    // Default is Tokyo
    private var currentLocation:CLLocation
    private var currentLocality:String
    
    override init() {
        currentLocation = CLLocation(latitude: 35.6895, longitude: 139.6917)
        currentLocality = "Minato"
    }
    
    func getLocation() ->CLLocation {
        return currentLocation
    }
    
    func getDistanceFrom(targetLocation:CLLocation) -> Double {
        return currentLocation.distanceFromLocation(targetLocation) / 1000.0
    }
    
    func setLocation(location:CLLocation) -> Void{
        currentLocation = location
    }
    
    func setLocality(locality:String) -> Void{
        currentLocality = locality
    }
    
    func getLocality(locality:String) -> String{
        return currentLocality
    }
    
    class var sharedInstance : LocationService {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : LocationService? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = LocationService()
        }
        return Static.instance!
    }
}