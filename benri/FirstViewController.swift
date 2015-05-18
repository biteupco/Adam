//
//  FirstViewController.swift
//  benri
//
//  Created by Kittikorn Ariyasuk on 4/26/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

let discoverCloseNotificationKey = "me.gobbl.adam.discoverCloseNotificationKey"
let discoverSearchNotificationKey = "me.gobbl.adam.discoverSearchNotificationKey"

class FirstViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var menuTableView: UITableView!
    
    var menuArray : NSMutableArray = []
    var restuarantList:NSMutableDictionary = NSMutableDictionary()
    
    var const:Const         = Const.sharedInstance
    var locationService:LocationService = LocationService.sharedInstance
    var restaurantCache:RestaurantCache = RestaurantCache.sharedInstance
    
    let locationManager     = CLLocationManager()
    var populateLength      = 3
    var currentLoadedIndex  = 0
    var isPopulating        = false
    var isInitiated         = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.currentLoadedIndex = 0
        self.populateLength     = 3
        
        self.menuTableView.delegate = self
        self.menuTableView.dataSource = self
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if (CLLocationManager.authorizationStatus() == .NotDetermined)  {
            self.locationManager.requestAlwaysAuthorization()
        } else {
            isInitiated = true
            self.populateMenu(true, tags: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initMenu() {
        struct Static {
            static var onceToken : dispatch_once_t = 0
        }
        dispatch_once(&Static.onceToken) {
            self.populateMenu(false, tags: nil)
        }
    }
    
    func requestGeo() {
        locationManager.startUpdatingLocation()
    }
    
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
                isUserAnswered = true
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isLocationEnable")
            }
            if isUserAnswered {
                locationManager.startUpdatingLocation()
                self.initMenu()
                if !self.isInitiated {
                    self.isInitiated = true
                }
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
            let coordinate:CLLocationCoordinate2D = placemark.location.coordinate
            locationService.setLocation(placemark.location)
            locationService.setLocality(placemark.locality)
        }
    }
    
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location" + error.localizedDescription)
    }
    
    func loadRestaurantCache(restaurantList:[String]) -> [String] {
        var _newList:[String] = []
        for restaurantID in restaurantList {
            if let restuarant = restaurantCache.loadRestaurant(restaurantID) as Restaurant! {
                self.restuarantList.setValue(restuarant, forKey: restaurantID)
            }
            else {
                _newList.append(restaurantID)
            }
        }
        return _newList
    }
    
    func loadRestuarantInfo(restaurantList:[String], resetFlag:Bool) {
        var restaurantSVAPI:RestaurantSVAPI = RestaurantSVAPI()
        for restaurantID in restaurantList {
            restaurantSVAPI.getRestaurantByID(restaurantID,
                limit: 1,
                successCallback: {(somejson)-> Void in
                    if let json: AnyObject = somejson{
                        let myJSON = JSON(json)
                        var restaurant = Restaurant()
                        restaurant.initByJSON(myJSON)
                        self.restuarantList.setValue(restaurant, forKey: restaurant.id)
                        self.restaurantCache.cacheRestaurant(restaurant.id, restaurant: restaurant)
                    }
                    self.isPopulating = false
                    
                }, errorCallback: {()->Void in
                    println("Error")
                    self.isPopulating = false
            })
        }
    }
    
    func populateMenu(isReset:Bool, tags: String?) -> Void {
        if self.isPopulating {
            return
        }
        if isReset {
            self.currentLoadedIndex = 0
            self.menuArray = []
        }
        
        isPopulating = true
        var menuSVAPI:MenuSVAPI = MenuSVAPI()
        if let searchTag = tags {
            menuSVAPI.getMenuByTags(searchTag,
                start: self.currentLoadedIndex,
                limit: self.populateLength,
                successCallback: {(somejson) -> Void in
                    if let json: AnyObject = somejson{
                        var resIDList = [String]()
                        
                        self.currentLoadedIndex += self.populateLength
                        let myJSON = JSON(json)
   
                        for (index: String, itemJSON: JSON) in myJSON["items"] {
                            var menu:Menu = Menu()
                            menu.initByJSON(myJSON)
                            resIDList.append(menu.storeID)
                            self.menuArray.addObject(menu)
                        }
                        
                        var needLoadIDList:[String] = self.loadRestaurantCache(resIDList)
                        if needLoadIDList.count > 0 {
                            self.loadRestuarantInfo(needLoadIDList, resetFlag: isReset)
                        }
                        else {
                            if isReset {
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.menuTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Bottom)
                                }
                            } else {
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.menuTableView.reloadData()
                                }
                            }
                            self.isPopulating = false
                            //activityView.stopAnimating()
                        }
                    }
                },
                errorCallback: {()->Void in
                    println("Error")
                    self.isPopulating = false
            })
        } else {
            menuSVAPI.getMenu(self.currentLoadedIndex,
                limit: self.populateLength,
                successCallback: {(somejson) -> Void in
                    if let json: AnyObject = somejson{
                        self.currentLoadedIndex += self.populateLength
                        let lastItem = self.menuArray.count
                        
                        let myJSON = JSON(json)
                        for (index: String, itemJSON: JSON) in myJSON["items"] {
                            
                            
                            if let storeName:String = itemJSON["name"].rawString() {
                                if let storeLocationStr = itemJSON["geolocation"].rawString()  {
                                    let longitudeDbl = 35.66 //itemJSON["geolocation"]["lon"].double!
                                    let latitudeDbl  = 139.733//itemJSON["geolocation"]["lat"].double!
                                    let storeLocation = CLLocation(latitude: latitudeDbl, longitude: longitudeDbl)
                                    let storeDistance = self.locationService.getDistanceFrom(storeLocation)
                                    let storeAddress  = "Roppongi"//itemJSON["address"].string!
                                    
                                    for (index: String, menuJSON: JSON) in itemJSON["menus"] {
                                        var imgURLString:String = menuJSON["images"][0].string!
                                        
                                        imgURLString = imgURLString.stringByReplacingOccurrencesOfString("\"", withString: "", options:  NSStringCompareOptions.LiteralSearch, range: nil)
                                        
                                        if let menuName = menuJSON["name"].rawString() {
                                            if let imgURL = NSURL(string: imgURLString) {
                                                if let pointVal = menuJSON["rating"].int {
                                                    if let price    = menuJSON["price"].float {
                                                        var menu = Menu(menuName: menuName,
                                                            storeName: storeName,
                                                            imgURL: imgURL,
                                                            distanceVal: storeDistance,
                                                            pointVal: pointVal,
                                                            price: price,
                                                            address: storeAddress,
                                                            latitude: latitudeDbl,
                                                            longitude: longitudeDbl)
                                                        self.menuArray.addObject(menu)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                        if isReset {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.menuTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Bottom)
                            }
                            
                        } else {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.menuTableView.reloadData()
                                
                                //self.menuTableView.
                                //self.menuTableView.reloadSections(NSIndexSet(index: lastItem), withRowAnimation: UITableViewRowAnimation.Bottom)
                            }
                        }
                        self.isPopulating = false
                    }
                },
                errorCallback: {()->Void in
                    println("Error")
            })
            
        }
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if !isInitiated {
            return
        }
        if scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8 {
            if let searchTag = const.getConst("search", key: "tag") {
                self.populateMenu(false, tags: searchTag)
            } else {
                self.populateMenu(false, tags: nil)
            }
        }
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:MenuCell = tableView.dequeueReusableCellWithIdentifier("menuCell", forIndexPath: indexPath) as! MenuCell
        if menuArray.count <= 0 {
            return cell
        }
        let menu = menuArray.objectAtIndex(indexPath.row) as! Menu
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)){
            println(menu.imgURL)
            cell.setImageByURL(menu.imgURL)
        }
        
        let storeDistance = self.locationService.getDistanceFrom(CLLocation(latitude: menu.latitude, longitude: menu.longitude))
        
        cell.setMenuCell(menu.menuName, storeName: menu.storeName, distanceVal: storeDistance, pointVal: menu.pointVal, price: menu.price, address: menu.address)
        
        return cell
        
    }
    /*
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count
    }*/
/*
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        println("#############################")
        let cell:MenuCell = tableView.dequeueReusableCellWithIdentifier("menuCell", forIndexPath: indexPath) as! MenuCell
        
        if menuArray.count <= 0 {
            return cell
        }
        
        let menu = menuArray.objectAtIndex(indexPath.row) as! Menu
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)){
            println(menu.imgURL)
            cell.setImageByURL(menu.imgURL)
        }
        
        let storeDistance = self.locationService.getDistanceFrom(CLLocation(latitude: menu.latitude, longitude: menu.longitude))
        
        cell.setMenuCell(menu.menuName, storeName: menu.storeName, distanceVal: storeDistance, pointVal: menu.pointVal, price: menu.price, address: menu.address)
        
        return cell
    }

*/
}

