//
//  TagsViewController.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 7/20/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import UIKit
import SwiftyJSON

class TagsViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tagsTableView: UITableView!
    
    var tags: NSMutableArray = []
    
    var const:Const                         = Const.sharedInstance
    var locationService:LocationService     = LocationService.sharedInstance
    var imgCache:ImageCache                 = ImageCache.sharedInstance
    var ldIndicator:LoadingIndicator        = LoadingIndicator.sharedInstance
    var filterManager:FilterManager         = FilterManager.sharedInstance
    
    var populateLength      = 10
    var currentLoadedIndex  = 0
    
    var isPopulating        = false
    var isInitiated         = false
    
    @IBAction func returnFromTutorialSegueActions(sender: UIStoryboardSegue) {
        if sender.identifier == "tutorialSegueUnwind" {
            self.loadTags()
            self.tagsTableView.delegate = self
            self.tagsTableView.dataSource = self
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
                statusView.backgroundColor = UIColor.whiteColor()
                //statusView.backgroundColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
                self.view.addSubview(statusView)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tags.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tagsTableView.dequeueReusableCellWithIdentifier("TagCell") as! TagCell
        
        if self.tags.count < 0 {
            return cell
        }
        
        let tag = tags.objectAtIndex(indexPath.row) as! Tag
        cell.setTagInfo(tag)
        //cell.request?.cancel()
        //cell.setImageByURL(menu.imgURL)
        //cell.setMenu(menu, restaurant: restaurant)
        //println(locationService.getCurrentLocation())
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }

}
