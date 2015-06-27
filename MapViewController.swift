//
//  MapViewController.swift
//  adam
//
//  Created by ariyasuk-k on 6/24/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MapViewController: UIViewController, GMSMapViewDelegate {

    @IBOutlet weak var addressTextView: UITextView!
    @IBAction func backToDetail(sender: AnyObject) {
        self.performSegueWithIdentifier("backFromMapView", sender: self)
    }
    
    @IBOutlet weak var mapView: UIView!
    var restaurant: Restaurant!
    
    var gMap:GMSMapView!
    var gCamera:GMSCameraPosition!
    var destinationMarker:GMSMarker!
    var steps:Array<JSON>!
    var polyline:GMSPolyline!
    
    var apiKey:String!
    
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
        
        if let path = NSBundle.mainBundle().pathForResource("APISetting", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
                if let googleMapAPI = dict["GoogleDirection"] as? String{
                    self.apiKey = googleMapAPI
                }
            }
        }
        
        if restaurant != nil {
            
            addressTextView.text = restaurant.address
            
            let screenWidth = UIScreen.mainScreen().bounds.width
            let screenHeight = UIScreen.mainScreen().bounds.height
            
            self.gCamera = GMSCameraPosition.cameraWithLatitude(restaurant.location.coordinate.latitude,
                longitude: restaurant.location.coordinate.longitude, zoom: 17)
            
            self.gMap = GMSMapView.mapWithFrame(CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight), camera: self.gCamera)
            self.gMap.myLocationEnabled = true
            self.gMap.settings.myLocationButton = true
            self.gMap.settings.compassButton = true
            self.gMap.delegate = self
            
            self.destinationMarker = GMSMarker()
            self.destinationMarker.position = self.gCamera.target
            self.destinationMarker.snippet = restaurant.name
            self.destinationMarker.appearAnimation = kGMSMarkerAnimationPop
            self.destinationMarker.map = self.gMap
            
            self.mapView.addSubview(self.gMap)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Google Maps Delegate
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        if let startLocation = self.gMap.myLocation {
            fetchDirectionsFrom(startLocation.coordinate, to: self.destinationMarker.position, completion: { (optionalRoute) -> Void in
            
            })
        }
        
        return true
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
            
            /*fetchDirectionsFrom(self.gMap.myLocation.coordinate, to: self.destinationMarker.position, completion: { (optionalRoute) -> Void in
                
            })*/
            
            
        }
    }
    
    
    func fetchDirectionsFrom(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, completion: ((String?) -> Void)) -> ()
    {
        let urlString = "https://maps.googleapis.com/maps/api/directions/json"
        let parameters:[String:AnyObject] = [
            "key" : self.apiKey,
            "origin" : [String(stringInterpolationSegment: from.latitude),String(stringInterpolationSegment: from.longitude)],
            "destination" : [String(stringInterpolationSegment: to.latitude),String(stringInterpolationSegment: to.longitude)],
            "mode" : "walking"
        ]
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        Alamofire.request(.GET, urlString, parameters: parameters, encoding: .URL).responseJSON{
            (req, res, json, error) in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if error != nil {
                println(error)
            } else {
                
                let myJSON = JSON(json!)
                self.steps = myJSON["routes"][0]["legs"][0]["steps"].arrayValue
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    if let encodePath = myJSON["routes"][0]["overview_polyline"]["points"].string {
                        var path:GMSPath = GMSPath(fromEncodedPath: encodePath)
                        self.polyline = GMSPolyline(path: path)
                        self.polyline.strokeWidth = 5
                        self.polyline.strokeColor = UIColor.blueColor()
                        self.polyline.map = self.gMap
                    }
                })
            }
        }
    }
}
