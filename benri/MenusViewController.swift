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

class MenusViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!

    
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
    
    var populateLength      = 5
    var currentLoadedIndex  = 0
    var searchTag           = ""
    var searchLocation:CLLocation!
    
    var isPopulating        = false
    var isInitiated         = false
    var lastContentOffset:CGFloat = 0.0

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        struct Static {
            static var token: dispatch_once_t = 0;
        }
        dispatch_once(&Static.token) {
            var statusView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 20))
            statusView.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
            self.view.addSubview(statusView)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotificationDiscoverClose", name: discoverCloseNotificationKey, object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotificationDiscoverSearch", name: discoverSearchNotificationKey, object: nil)
        
        self.currentLoadedIndex = 0
        self.populateLength     = 5
        
        self.menuTableView.delegate = self
        self.menuTableView.dataSource = self
        
        self.menuTableView.hidden = true
        self.navBar.topItem?.title = self.searchTag
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(10 * NSEC_PER_MSEC)), dispatch_get_main_queue(), { () -> Void in
            self.populateMenu(true, tags: self.searchTag, location:self.locationService.locationToLonLat(self.searchLocation))
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        if scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8 {
            self.populateMenu(false, tags: self.searchTag, location:self.locationService.locationToLonLat(self.searchLocation))
        }
        
        let translation = scrollView.panGestureRecognizer.translationInView(scrollView.superview!)
        if translation.y > 0 {
            //setVisibleNavigationBar(true)
        
        } else {
            //setVisibleNavigationBar(false)
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
        if self.menuTableView.hidden {
            self.menuTableView.hidden = false
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
    
    override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
        return RightCustomUnwindSegue(identifier: identifier, source: fromViewController, destination: toViewController)
    }
}

