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
    var ratingImages:[UIImageView]!
    
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
    

    @IBOutlet weak var ratingStar1: UIImageView!
    @IBOutlet weak var ratingStar2: UIImageView!
    @IBOutlet weak var ratingStar3: UIImageView!
    @IBOutlet weak var ratingStar4: UIImageView!
    @IBOutlet weak var ratingStar5: UIImageView!
    
    
    
    @IBAction func orderNow(sender: AnyObject) {
        println("orderNow")
        var orderDialogVC: OrderDialogViewController = OrderDialogViewController(nibName: "OrderDialogViewController", bundle: nil)
        self.addChildViewController(orderDialogVC)
        self.view.addSubview(orderDialogVC.view)
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
        let screenWidth = UIScreen.mainScreen().bounds.width
        self.ratingImages = [ratingStar1, ratingStar2, ratingStar3, ratingStar4, ratingStar5]
        
        
        // Menu Name
        self.navItem.title = menu.menuName
        
        // Restaurant Name
        self.restaurantLabel.text = restaurant.name
        
        // Star Rating
        if menu.ratingCount > 0 {
            let rating:Float = Float(menu.ratingTotal) / Float(menu.ratingCount)
            self.setRatingStar(rating)
        } else {
            self.hideRatingStar()
        }
        
        // Distance Label
        let storeDistance = self.locationService.getDistanceFrom(restaurant.location)
        _setDistanceLabel(storeDistance)
        
        // Price Label
        _setPriceLabel(menu.price, currencyCode: menu.currency)
        
        // Menu Image
        self.request?.cancel()
        self.imageView.frame = CGRectMake(0, 0, screenWidth, imageView.frame.size.height * screenWidth/imageView.frame.size.width)
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
        
        // Map
        var camera = GMSCameraPosition.cameraWithLatitude(restaurant.location.coordinate.latitude,
            longitude: restaurant.location.coordinate.longitude, zoom: 16)
        var myMap:GMSMapView = GMSMapView.mapWithFrame(CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth * 3 / 4), camera: camera)
        myMap.settings.setAllGesturesEnabled(false)
        
        // Map marker
        var marker = GMSMarker()
        marker.position = camera.target
        marker.snippet = restaurant.name
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = myMap
        
        // Map Address
        self.addressTextView.text = restaurant.address
        self.addressTextView.contentInset = UIEdgeInsetsMake(5, 5,
            5, 5)
        
        // Function for tap on map
        var singleTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "showMap")
        self.mapView.addGestureRecognizer(singleTap)
        
        
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
    
    private func updateDistantLabelVisible() {
        if let isLocationEnable:AnyObject = NSUserDefaults.standardUserDefaults().valueForKey("isLocationEnable") {
            self.distanceLabel.hidden = !(isLocationEnable as! Bool)
        } else {
            self.distanceLabel.hidden = false
        }
    }
    
    private func _setDistanceLabel(distance: Double) {
        var formatter : String = ""
        if distance < 1 {
            let meterD = Int(distance * 1000)
            formatter = String(format: "%d m", meterD)
        } else {
            formatter = String(format: "%.02f km", distance)
        }
        self.distanceLabel.text = formatter
        self.updateDistantLabelVisible()
    }
    
    private func resizePriceLabelFrame(priceText: String){
        //Calculate the expected size based on the font and linebreak mode of your label
        var maximumLabelSize: CGSize = CGSizeMake(320, 60)
        let myPriceText: NSString = priceText as NSString
        let expectedLabelSize: CGSize = myPriceText.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(17.0)])
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        
        var newFrame: CGRect = priceLabel.frame
        newFrame.size.width = round(expectedLabelSize.width)
        newFrame.origin.x   = screenWidth - newFrame.size.width
        
        priceLabel.text = priceText
        priceLabel.frame = newFrame
        priceLabel.textAlignment = NSTextAlignment.Center
        
    }
    
    private func _setPriceLabel(price: Float, currencyCode:String){
        var const:Const = Const.sharedInstance
        var priceText = ""
        if price % 1 == 0 {
            priceText = String(format: "%.0f", price)
        }
        else {
            priceText = String(format: "%.2f", price)
        }
        
        let currencySymbol = CurrencyConverter.codeToSymbol(currencyCode)
        priceText = " " + currencySymbol + " " + priceText + "  "
        self.priceLabel.text = priceText
    }
    
    private func setRatingStar(rating:Float) {
        for (index, ratingImage) in enumerate(ratingImages) {
            if Float(index) + 1.0 <= floor(rating) {
                ratingImage.image = UIImage(named: "fullStar")
            } else if Float(index) + 1.0 - rating > 0.25 {
                if Float(index) + 1.0 - rating > 0.8 {
                    ratingImage.image = UIImage(named: "fullStar")
                } else {
                    ratingImage.image = UIImage(named: "halfStar")
                }
            } else {
                ratingImage.image = UIImage(named: "emptyStar")
            }
        }
    
    }
    
    private func hideRatingStar() {
        for ratingImage in ratingImages {
            ratingImage.hidden = true
        }
    }
    
}
