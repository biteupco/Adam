//
//  TagsViewController.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 7/20/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import UIKit
import SwiftyJSON

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

class TagsViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tagsTableView: UITableView!
    @IBOutlet weak var locationButton: UIButton!
    
    @IBAction func returnToTag(sender: UIStoryboardSegue){
        if sender.identifier == "didSelectLocation" {
            // update location
            self.locationButton.setTitle(locationSearchText + moreLocationText, forState: .Normal)
        }
    }
    
    var tags: NSMutableArray = []
    
    var const:Const                         = Const.sharedInstance
    var locationService:LocationService!
    var imgCache:ImageCache                 = ImageCache.sharedInstance
    var ldIndicator:LoadingIndicator        = LoadingIndicator.sharedInstance
    var filterManager:FilterManager         = FilterManager.sharedInstance
    
    var populateLength      = 10
    var currentLoadedIndex  = 0
    
    var isPopulating        = false
    var isInitiated         = false
    
    var locationSearch:CLLocation!
    var locationSearchText  = "Current Location"
    var moreLocationText    = " ⌄"
    
    @IBAction func returnFromTutorialSegueActions(sender: UIStoryboardSegue) {
        if sender.identifier == "tutorialSegueUnwind" {
            self.tagsTableView.delegate = self
            self.tagsTableView.dataSource = self
            self.locationService = LocationService.sharedInstance
            
            self.loadTags()
        }
    }
    
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
                self.locationButton.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var userDefault = NSUserDefaults.standardUserDefaults()
        if (userDefault.boolForKey("didFinishedTutorial")){
            self.tagsTableView.delegate = self
            self.tagsTableView.dataSource = self
            self.locationService = LocationService.sharedInstance
            // Delay execution for 10 miliseconds.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(10 * NSEC_PER_MSEC)), dispatch_get_main_queue(), { () -> Void in
                self.loadTags()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadTags() {
        let tagSVAPI:TagSVAPI = TagSVAPI()
        self.ldIndicator.activityImageView.startAnimating()
        self.view.addSubview(self.ldIndicator.activityImageView)
        
        tagSVAPI.getTags(currentLoadedIndex, limit: populateLength,
            successCallback: { (json) -> Void in
                if let json: AnyObject = json {
                    
                    let tagJSON = JSON(json)
                    for (index: String, itemJSON: JSON) in tagJSON["items"] {
                        var newTag = Tag()
                        newTag.initByJSON(itemJSON)
                        self.tags.addObject(newTag)
                    }
                    self.tagsTableView.reloadData()
                }

                self.ldIndicator.activityImageView.stopAnimating()
                self.ldIndicator.activityImageView.removeFromSuperview()
            }) { () -> Void in
                
                self.ldIndicator.activityImageView.stopAnimating()
                self.ldIndicator.activityImageView.removeFromSuperview()
        }
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "ShowMenuSegue") {
            // pass data to next view
            let viewController:MenusViewController = segue.destinationViewController as! MenusViewController
            
            if let indexPath = self.tagsTableView.indexPathForSelectedRow(){
                let searchTag =  self.tags.objectAtIndex(indexPath.row) as! Tag
                viewController.searchTag = searchTag.tagName
                viewController.searchLocation = self.locationSearch
            }
            if self.locationSearch == nil {
                viewController.searchLocation = self.locationService.getCurrentLocation()
            }
        }
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tags.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tagsTableView.dequeueReusableCellWithIdentifier("TagCell") as! TagCell
        
        if self.tags.count < 0 {
            return cell
        }
        
        let tag = tags.objectAtIndex(indexPath.row) as! Tag
        cell.request?.cancel()
        cell.setTagInfo(tag)
        //cell.setImageByURL(menu.imgURL)
        //cell.setMenu(menu, restaurant: restaurant)
        //println(locationService.getCurrentLocation())
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("HI")
        print(locationService.getCurrentLocation())
    }

}
