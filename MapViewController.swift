//
//  MapViewController.swift
//  adam
//
//  Created by ariyasuk-k on 6/24/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    @IBOutlet weak var addressTextView: UITextView!
    @IBAction func backToDetail(sender: AnyObject) {
        self.performSegueWithIdentifier("backFromMapView", sender: self)
    }
    
    @IBOutlet weak var mapView: UIView!
    var restaurant: Restaurant!
    
    var gMap:GMSMapView!
    var gCamera:GMSCameraPosition!
    
    var destinationMarker:GMSMarker!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.gMap.myLocationEnabled = true
        self.gMap.addObserver(self, forKeyPath: "myLocation", options: .New, context: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.gMap.removeObserver(self, forKeyPath: "myLocation")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if restaurant != nil {
            
            addressTextView.text = restaurant.address
            
            let screenWidth = UIScreen.mainScreen().bounds.width
            let screenHeight = UIScreen.mainScreen().bounds.height
            
            self.gCamera = GMSCameraPosition.cameraWithLatitude(restaurant.location.coordinate.latitude,
                longitude: restaurant.location.coordinate.longitude, zoom: 17)
            
            self.gMap = GMSMapView.mapWithFrame(CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight), camera: self.gCamera)
            
            self.gMap.settings.myLocationButton = true
            self.gMap.settings.compassButton = true
            
            self.destinationMarker = GMSMarker()
            self.destinationMarker.position = self.gCamera.target
            self.destinationMarker.snippet = restaurant.name
            self.destinationMarker.appearAnimation = kGMSMarkerAnimationPop
            self.destinationMarker.map = self.gMap
            
            //self.mapView.insertSubview(myMap, aboveSubview: addressTextView)
            self.mapView.addSubview(self.gMap)
            
            
        }
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

    
    // MARK: Observer
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "myLocation" && object.isKindOfClass(GMSMapView) {
            //self.gMap.animateToCameraPosition(GMSCameraPosition.cameraWithTarget(self.gMap.myLocation.coordinate, zoom: 14))
            
        }
    }
}
