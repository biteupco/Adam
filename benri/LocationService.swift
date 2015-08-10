//
//  LocationService.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 2/24/15.
//  Copyright (c) 2015 Benri. All rights reserved.
//

import Foundation
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
    // Default is Tokyo
    private var currentLocation:CLLocation
    private var currentLocality:String
    let locationManager     = CLLocationManager()
    
    override init() {
        currentLocation = CLLocation(latitude: 35.664122, longitude: 139.729426)
        currentLocality = "Minato"
    }
    func initDelagate() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            self.locationManager.requestAlwaysAuthorization()
        }
    }
    
    func requestGeo() {
        self.locationManager.startUpdatingLocation()
    }
    // MARK Location manager delegate
    
    // authorization status
    func locationManager(manager: CLLocationManager!,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            var isUserAnswered = false
            
            switch status {
            case CLAuthorizationStatus.Restricted:
                isUserAnswered = true
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isLocationEnable")
            case CLAuthorizationStatus.Denied:
                isUserAnswered = true
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isLocationEnable")
            case CLAuthorizationStatus.NotDetermined:
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isLocationEnable")
            default:
                self.locationManager.startUpdatingLocation()
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isLocationEnable")
            }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in
            if (error != nil) {
                println("Reverse geocoder failed with error" + error.localizedDescription)
                return
            }
            
            if placemarks.count > 0 {
                let pm = placemarks[0] as! CLPlacemark
                self.updateLocationInfo(pm)
            } else {
                println("Problem with the data received from geocoder")
            }
        })
    }
    
    func updateLocationInfo(placemark: CLPlacemark){
        if placemark.location != nil {
            //stop updating location to save battery life
            self.locationManager.stopUpdatingLocation()
            self.currentLocation = placemark.location
            let coordinate:CLLocationCoordinate2D = placemark.location.coordinate
            self.setLocation(placemark.location)
            self.setLocality(placemark.locality)
        }
    }
    
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location" + error.localizedDescription)
    }
    
    func getCurrentLocation() -> CLLocation {
        return currentLocation
    }
    
    func locationToLonLat(location:CLLocation) -> [CGFloat] {
        return [CGFloat(location.coordinate.longitude), CGFloat(location.coordinate.latitude)]
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
            Static.instance!.initDelagate()
        }
        return Static.instance!
    }
}