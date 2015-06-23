//
//  MenuDetailViewController.swift
//  adam
//
//  Created by ariyasuk-k on 6/23/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import MapKit
import UIKit
import Alamofire

class MenuDetailViewController: UIViewController {
    
    var menu:Menu!
    var restaurant:Restaurant!
    
    var imageCache:ImageCache = ImageCache.sharedInstance
    
    var request: Alamofire.Request?
    
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var placementView: UIView!
    @IBOutlet weak var restaurantLabel: UILabel!

    @IBAction func backToFirstPage(sender: AnyObject) {
        self.performSegueWithIdentifier("backFromMenuDetail", sender: self)
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.restaurantLabel.text = restaurant.name
        let screenWidth = UIScreen.mainScreen().bounds.width
        
        self.imageView.frame = CGRectMake(0, 0, screenWidth, imageView.frame.size.height * screenWidth/imageView.frame.size.width)
        
        
        self.request?.cancel()
        if let image = imageCache.loadImage(menu.imgURL) {
            self.imageView.image = image
        } else {
            self.request = Alamofire.request(.GET, menu.imgURL).validate(contentType: ["image/*"]).responseImage() {
                (request, _, image, error) in
                if error == nil && image != nil {
                    self.imageCache.cacheImage(request.URL, image: image!)
                    self.imageView.image = image
                }
            }
        }
        
        self.navItem.title = menu.menuName
        
        var camera = GMSCameraPosition.cameraWithLatitude(-33.86,
            longitude: 151.20, zoom: 6)
        var myMap = GMSMapView.mapWithFrame(CGRect(x: 0, y: 0, width: self.mapView.bounds.width, height: self.mapView.bounds.height), camera: camera)
        self.mapView.addSubview(myMap)
        //let mapSnapshot = myMap.snapshotViewAfterScreenUpdates(true)
        
        /*UIGraphicsBeginImageContext(myMap.frame.size)
        myMap.layer.renderInContext(UIGraphicsGetCurrentContext())
        var screenShotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.imageView.image = screenShotImage*/
        
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

}
