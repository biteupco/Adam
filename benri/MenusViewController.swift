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
import Mixpanel

let discoverCloseNotificationKey = "me.gobbl.adam.discoverCloseNotificationKey"
let discoverSearchNotificationKey = "me.gobbl.adam.discoverSearchNotificationKey"

enum ScreenSize {
    case UNDEFINED,
    IPHONE_3_5_INCH,
    IPHONE_4_INCH,
    IPHONE_4_7_INCH,
    IPHONE_5_5_INCH
}

func getDeviceSize()->ScreenSize {
    let screenSize: CGRect = UIScreen.mainScreen().bounds

    if screenSize.width == 320.0 {
        if screenSize.height == 480.0 {
            return ScreenSize.IPHONE_3_5_INCH
        } else {
            return ScreenSize.IPHONE_4_INCH
        }
    } else if screenSize.width == 375.0 {
        return ScreenSize.IPHONE_4_7_INCH
    } else if screenSize.width == 414.0 {
        return ScreenSize.IPHONE_5_5_INCH
    }
    return ScreenSize.UNDEFINED
}

class MenusViewController: UIViewController, CLLocationManagerDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBAction func onSearchClick(sender: AnyObject) {
        self.menuTableView.userInteractionEnabled = false
        self.searchButton.enabled = false
        self.requestGeo()
        var discoverVC: DiscoverViewConroller = DiscoverViewConroller(nibName: "DiscoverView", bundle: nil)
        var discoverView = discoverVC.view
        self.tabBarController?.addChildViewController(discoverVC)
        self.tabBarController?.view.addSubview(discoverVC.view)
    }
    
    
    
    @IBAction func returnFromMenuDetailSegueActions(sender: UIStoryboardSegue) {
        if sender.identifier == "backFromMenuDetail" {
            println("backFromMenuDetail")
        }
    }
    
    var menuArray : NSMutableArray = []
    var restuarantList:NSMutableDictionary = NSMutableDictionary()
    
    var const:Const         = Const.sharedInstance
    var locationService:LocationService = LocationService.sharedInstance
    var restaurantCache:RestaurantCache = RestaurantCache.sharedInstance
    var imgCache:ImageCache = ImageCache.sharedInstance
    var ldIndicator:LoadingIndicator = LoadingIndicator.sharedInstance
    
    let locationManager     = CLLocationManager()
    var populateLength      = 5
    var currentLoadedIndex  = 0
    var isPopulating        = false
    var isInitiated         = false
    var lastContentOffset:CGFloat = 0.0

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        var userDefault = NSUserDefaults.standardUserDefaults()
        if !(userDefault.boolForKey("didFinishedTutorial")) {
            var vc = self.storyboard?.instantiateViewControllerWithIdentifier("TutorialViewController") as! TutorialViewController
            vc.modalPresentationStyle = UIModalPresentationStyle.FullScreen
            self.presentViewController(vc, animated: true, completion: nil)
        } else {
            struct Static {
                static var token: dispatch_once_t = 0;
            }
            dispatch_once(&Static.token) {
                var statusView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 20))
                statusView.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
                self.view.addSubview(statusView)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotificationDiscoverClose", name: discoverCloseNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotificationDiscoverSearch", name: discoverSearchNotificationKey, object: nil)
        
        self.currentLoadedIndex = 0
        self.populateLength     = 5
        
        self.menuTableView.delegate = self
        self.menuTableView.dataSource = self
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if (CLLocationManager.authorizationStatus() == .NotDetermined)  {
            self.locationManager.requestAlwaysAuthorization()
        } else {
            isInitiated = true
            // Delay execution for 10 miliseconds.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(10 * NSEC_PER_MSEC)), dispatch_get_main_queue(), { () -> Void in
                self.populateMenu(true, tags: nil, location:self.locationService.locationToLonLat(self.locationService.getCurrentLocation()))
            })
            
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
            self.populateMenu(true, tags: nil, location:self.locationService.locationToLonLat(self.locationService.getCurrentLocation()))
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
                if !self.isInitiated {
                    self.initMenu()
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
            else if !contains(_newList, restaurantID) {
                _newList.append(restaurantID)
            }
        }
        return _newList
    }
    
    func loadRestuarantInfo(restaurantList:[String], isReset:Bool) {
        var restaurantSVAPI:RestaurantSVAPI = RestaurantSVAPI()
        
        restaurantSVAPI.getRestaurantByIDs(restaurantList,
            successCallback: {(somejson)-> Void in
                if let json: AnyObject = somejson{
                    let myJSON = JSON(json)
                    for (index: String, itemJSON: JSON) in myJSON["items"] {
                        var restaurant = Restaurant()
                        restaurant.initByJSON(itemJSON)
                        self.restuarantList.setValue(restaurant, forKey: restaurant.id)
                        self.restaurantCache.cacheRestaurant(restaurant.id, restaurant: restaurant)
                    }
                    if isReset {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.menuTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Bottom)
                            self.ldIndicator.activityImageView.stopAnimating()
                            self.ldIndicator.activityImageView.removeFromSuperview()
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.menuTableView.reloadData()
                        }
                    }
                }
                self.isPopulating = false
                
            }, errorCallback: {()->Void in
                println("Error")
                self.isPopulating = false
        })
    }
    
    func populateMenu(isReset:Bool, tags: String?, location: [CGFloat]?) -> Void {
        if self.isPopulating {
            return
        }
        if isReset {
            self.currentLoadedIndex = 0
            self.menuArray = []
            self.menuTableView.reloadData()
            self.ldIndicator.activityImageView.startAnimating()
            self.view.addSubview(self.ldIndicator.activityImageView)
        }
        isPopulating = true
        var menuSVAPI:MenuSVAPI = MenuSVAPI()
        if let searchTag = tags {
            menuSVAPI.getMenuByTags(searchTag,
                location:location,
                start: self.currentLoadedIndex,
                limit: self.populateLength,
                successCallback: {(somejson) -> Void in
                    if let json: AnyObject = somejson{
                        var resIDList = [String]()
                        
                        self.currentLoadedIndex += self.populateLength
                        let myJSON = JSON(json)
   
                        for (index: String, itemJSON: JSON) in myJSON["items"] {
                            var menu:Menu = Menu()
                            menu.initByJSON(itemJSON)
                            resIDList.append(menu.restaurantID)
                            self.menuArray.addObject(menu)
                        }
                        var needLoadIDList:[String] = self.loadRestaurantCache(resIDList)
                        if needLoadIDList.count > 0 {
                            self.loadRestuarantInfo(needLoadIDList, isReset: isReset)
                        }
                        else {
                            if isReset {
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.menuTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Bottom)
                                    self.ldIndicator.activityImageView.stopAnimating()
                                    self.ldIndicator.activityImageView.removeFromSuperview()
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
            menuSVAPI.getMenu(location,
                start:self.currentLoadedIndex,
                limit: self.populateLength,
                successCallback: {(somejson) -> Void in
                    if let json: AnyObject = somejson{
                        var resIDList = [String]()
                        self.currentLoadedIndex += self.populateLength
                        let lastItem = self.menuArray.count
                        
                        let myJSON = JSON(json)
                        for (index: String, itemJSON: JSON) in myJSON["items"] {
                            var menu:Menu = Menu()
                            menu.initByJSON(itemJSON)
                            resIDList.append(menu.restaurantID)
                            self.menuArray.addObject(menu)
                        }
                        
                        var needLoadIDList:[String] = self.loadRestaurantCache(resIDList)
                        if needLoadIDList.count > 0 {
                            self.loadRestuarantInfo(needLoadIDList, isReset: isReset)
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
            })
            
        }
        
    }
    
    func setVisibleNavigationBar(isVisible:Bool) {
        // TODO use variable for magic number 64 , 20
        if isVisible {
            self.navBar.hidden = false
            if self.menuTableView.frame.origin.y == 20 {
                UIView.animateWithDuration(0.3, animations: {
                    self.menuTableView.frame = CGRectMake(self.menuTableView.frame.origin.x, 64, self.menuTableView.frame.size.width, self.menuTableView.frame.size.height - 44)
                })
            } else {
                UIView.animateWithDuration(0.3, animations: {
                    self.menuTableView.frame = CGRectMake(self.menuTableView.frame.origin.x, 64, self.menuTableView.frame.size.width, self.menuTableView.frame.size.height)
                })
            }
            
        } else {
            self.navBar.hidden = true
            if self.menuTableView.frame.origin.y == 64 {
                UIView.animateWithDuration(0.3, animations: {
                    self.menuTableView.frame = CGRectMake(self.menuTableView.frame.origin.x, 20, self.menuTableView.frame.size.width, self.menuTableView.frame.size.height + 44)
                })
            
            } else {
                UIView.animateWithDuration(0.3, animations: {
                    self.menuTableView.frame = CGRectMake(self.menuTableView.frame.origin.x, 20, self.menuTableView.frame.size.width, self.menuTableView.frame.size.height)
                })
            }
        }
    }
    
    func castCGFloat()->(String)->CGFloat {
        return { (invalue:String) -> CGFloat in
            if let n = NSNumberFormatter().numberFromString(invalue) {
                let result = CGFloat(n)
                return result
            }
            return 0.0
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if !isInitiated {
            return
            
        }
        
        if scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8 {
            if let locationSearch = const.getConst("search", key: "location"){
                let location:[CGFloat] = (split(locationSearch) {$0 == ","}).map(castCGFloat())
                if let searchTag = const.getConst("search", key: "tag") {
                    self.populateMenu(false, tags: searchTag, location:location)
                } else {
                    self.populateMenu(false, tags: nil, location:location)
                }
            
            } else {
                if let searchTag = const.getConst("search", key: "tag") {
                    self.populateMenu(false, tags: searchTag, location:nil)
                } else {
                    self.populateMenu(false, tags: nil, location:nil)
                }
            
            }
            
            
            
        }
        let translation = scrollView.panGestureRecognizer.translationInView(scrollView.superview!)
        if translation.y > 0 {
            setVisibleNavigationBar(true)
        
        } else {
            setVisibleNavigationBar(false)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:MenuCell = self.menuTableView.dequeueReusableCellWithIdentifier("menuCell") as! MenuCell
        
        if menuArray.count < 0 {
            return cell
        }
        
        let menu = menuArray.objectAtIndex(indexPath.row) as! Menu
        let restaurant = restuarantList.objectForKey(menu.restaurantID) as! Restaurant
        
        cell.request?.cancel()
        cell.setImageByURL(menu.imgURL)
        cell.setMenu(menu, restaurant: restaurant)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let deviceSize = getDeviceSize()
        if deviceSize == ScreenSize.IPHONE_3_5_INCH || deviceSize == ScreenSize.IPHONE_4_INCH {
            return 295.0;
        } else if deviceSize == ScreenSize.IPHONE_4_7_INCH {
            return 340.0;
        } else if deviceSize == ScreenSize.IPHONE_5_5_INCH {
            return 370.0;
        }
        return 400.0;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func updateNotificationDiscoverClose() {
        const.deleteConst("search", key: "picker")
    }
    
    func updateNotificationDiscoverSearch() {
        // Mixapanel Track
        if let locationSearch = const.getConst("search", key: "location"){
            let location:[CGFloat] = (split(locationSearch) {$0 == ","}).map(castCGFloat())
            if let searchTag = const.getConst("search", key: "picker") {
                var mixPanelInstance:Mixpanel = Mixpanel.sharedInstance()
                mixPanelInstance.track("Simulate Search Tag", properties: ["Tag" : searchTag])
                
                const.setConst("search", key: "tag", value: searchTag)
                self.populateMenu(true, tags: searchTag, location:location)
            }
        } else {
            if let searchTag = const.getConst("search", key: "picker") {
                //var mixPanelInstance:Mixpanel = Mixpanel.sharedInstance()
                //mixPanelInstance.track("Simulate Search Tag", properties: ["Tag" : searchTag])
                
                const.setConst("search", key: "tag", value: searchTag)
                self.populateMenu(true, tags: searchTag, location:nil)
            }
        }
        
        const.deleteConst("search", key: "picker")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if let mysegue = segue {
            if (mysegue.identifier == "showDetailSegue") {
                // pass data to next view
                let viewController:MenuDetailViewController = segue!.destinationViewController as! MenuDetailViewController
                
                if let indexPath = self.menuTableView.indexPathForSelectedRow(){
                    viewController.menu = menuArray.objectAtIndex(indexPath.row) as! Menu
                    viewController.restaurant = self.restuarantList.objectForKey(viewController.menu.restaurantID) as! Restaurant
                }
            }
            
        }
        
    }
}

