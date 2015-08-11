//
//  FavViewController.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 8/10/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import UIKit

class FavViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var menuTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    /*
    // MARK: - TableView
    */
    
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

}
