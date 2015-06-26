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
    var locationService:LocationService = LocationService.sharedInstance
    
    var request: Alamofire.Request?
    
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var placementView: UIView!
    @IBOutlet weak var restaurantLabel: UILabel!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    

    
    @IBAction func orderNow(sender: AnyObject) {
        println("orderNow")
    }
    @IBAction func backToFirstPage(sender: AnyObject) {
        self.performSegueWithIdentifier("backFromMenuDetail", sender: self)
    }
    
    @IBAction func returnFromMapView(sender: UIStoryboardSegue) {
        if sender.identifier == "backFromMapView" {
            println("backFromMapView")
        }
    }
    
    func showMap() {
        println("Show map")
        self.performSegueWithIdentifier("showMap", sender: self)
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
        var camera = GMSCameraPosition.cameraWithLatitude(restaurant.location.coordinate.latitude,
            longitude: restaurant.location.coordinate.longitude, zoom: 16)
        
        var myMap:GMSMapView = GMSMapView.mapWithFrame(CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth * 3 / 4), camera: camera)
        myMap.settings.setAllGesturesEnabled(false)
        
        
        var marker = GMSMarker()
        marker.position = camera.target
        marker.snippet = restaurant.name
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = myMap
        
      
        self.addressTextView.text = restaurant.address
        self.addressTextView.contentInset = UIEdgeInsetsMake(5, 5,
            5, 5)
        
        var singleTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "showMap")
        self.mapView.addGestureRecognizer(singleTap)
        
        
        let storeDistance = self.locationService.getDistanceFrom(restaurant.location)
        _setDistanceLabel(storeDistance)
        
        self.mapView.addSubview(myMap)        
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
    
    // MARK: - PrepareForSegue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMap" {
            var vc:MapViewController = segue.destinationViewController as! MapViewController
            vc.restaurant = self.restaurant
        }
    }
    
    func updateDistantLabelVisible() {
        if let isLocationEnable:AnyObject = NSUserDefaults.standardUserDefaults().valueForKey("isLocationEnable") {
            self.distanceLabel.hidden = !(isLocationEnable as! Bool)
        } else {
            self.distanceLabel.hidden = false
        }
    }
    
    func _setDistanceLabel(distance: Double) {
        var formatter : String = String(format: "%.02f km", distance)
        self.distanceLabel.text = formatter
        self.updateDistantLabelVisible()
    }
}