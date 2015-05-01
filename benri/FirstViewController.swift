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
    
    var const:Const         = Const.sharedInstance
    var locationService:LocationService = LocationService.sharedInstance
    
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
    
    func populateMenu(isReset:Bool, tags: String?) -> Void {
        if self.isPopulating {
            return
        }
        if isReset {
            self.currentLoadedIndex = 0
            self.menuArray = []
        }
        
        isPopulating = true
        var svapi:MenuSVAPI = MenuSVAPI()
        if let searchTag = tags {
            svapi.getMenuByTags(searchTag,
                start: self.currentLoadedIndex,
                limit: self.populateLength,
                successCallback: {(somejson) -> Void in
                    if let json: AnyObject = somejson{
                        self.currentLoadedIndex += self.populateLength
                        let myJSON = JSON(json)
                        for (index: String, itemJSON: JSON) in myJSON["items"] {
                            if let storeName:String = itemJSON["name"].rawString() {
                                if let storeLocationStr = itemJSON["geolocation"].rawString()  {
                                    let longitudeDbl = itemJSON["geolocation"]["lon"].double!
                                    let latitudeDbl  = itemJSON["geolocation"]["lat"].double!
                                    let storeLocation = CLLocation(latitude: latitudeDbl, longitude: longitudeDbl)
                                    let storeDistance = self.locationService.getDistanceFrom(storeLocation)
                                    let storeAddress  = itemJSON["address"].string!
                                    
                                    for (index: String, menuJSON: JSON) in itemJSON["menus"] {
                                        var imgURLString:String = menuJSON["images"][0].string!
                                        
                                        imgURLString = imgURLString.stringByReplacingOccurrencesOfString("\"", withString: "", options:  NSStringCompareOptions.LiteralSearch, range: nil)
                                        
                                        if let menuName = menuJSON["name"].rawString() {
                                            if let imgURL = NSURL(string: imgURLString) {
                                                if let pointVal = menuJSON["rating"].int {
                                                    if let price    = menuJSON["price"].float {
                                                        var menu:Menu = Menu(menuName: menuName,
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
                            }
                            
                            //self.menuTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
                        }
                        self.isPopulating = false
                        //activityView.stopAnimating()
                    }
                },
                errorCallback: {()->Void in
                    println("Error")
            })
        } else {
            svapi.getMenu(self.currentLoadedIndex,
                limit: self.populateLength,
                successCallback: {(somejson) -> Void in
                    if let json: AnyObject = somejson{
                        self.currentLoadedIndex += self.populateLength
                        let lastItem = self.menuArray.count
                        
                        let myJSON = JSON(json)
                        for (index: String, itemJSON: JSON) in myJSON["items"] {
                            if let storeName:String = itemJSON["name"].rawString() {
                                if let storeLocationStr = itemJSON["geolocation"].rawString()  {
                                    let longitudeDbl = itemJSON["geolocation"]["lon"].double!
                                    let latitudeDbl  = itemJSON["geolocation"]["lat"].double!
                                    let storeLocation = CLLocation(latitude: latitudeDbl, longitude: longitudeDbl)
                                    let storeDistance = self.locationService.getDistanceFrom(storeLocation)
                                    let storeAddress  = itemJSON["address"].string!
                                    
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
            cell.setImageByURL(menu.imgURL)
        }
        
        let storeDistance = self.locationService.getDistanceFrom(CLLocation(latitude: menu.latitude, longitude: menu.longitude))
        
        cell.setMenuCell(menu.menuName, storeName: menu.storeName, distanceVal: storeDistance, pointVal: menu.pointVal, price: menu.price, address: menu.address)
        
        return cell
    }


}

