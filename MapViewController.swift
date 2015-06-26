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
            println(self.gMap.myLocation.coordinate)
            
            println(destinationMarker.position)
            fetchDirectionsFrom(self.gMap.myLocation.coordinate, to: destinationMarker.position, completion: { (optionalRoute) -> Void in
                
            })
            
        }
    }
    
    func fetchDirectionsFrom(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, completion: ((String?) -> Void)) -> ()
    {
        let urlString = "https://maps.googleapis.com/maps/api/directions/json"//?key=\(self.apiKey)&origin=\(from.latitude),\(from.longitude)&destination=\(to.latitude),\(to.longitude)&mode=walking"
        
        let parameters:[String:AnyObject] = [
            "key" : self.apiKey,
            "origin" : [String(stringInterpolationSegment: from.latitude),String(stringInterpolationSegment: from.longitude)],
            "destination" : [String(stringInterpolationSegment: to.latitude),String(stringInterpolationSegment: to.longitude)],
            "mode" : "walking"
        ]
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        //AIzaSyDK-l1MAppwX8uz2iTlhOjvfnAtiJ6wV5U
        //AIzaSyDK-l1MAppwX8uz2iTlhOjvfnAtiJ6wV5U
        Alamofire.request(.GET, urlString, parameters: parameters, encoding: .URL).responseJSON{
            (req, res, json, error) in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if error != nil {
            
            } else {
                print(req)
                let myJSON = JSON(json!)
                println(myJSON)
                let routes = myJSON["routes"]
                if routes != nil {
                
                }
                
            }
            /*if let routes = myJSON["routes"] as? [AnyObject] {
                if let route = routes.first as? [String : AnyObject] {
                    if let polyline = route["overview_polyline"] as AnyObject? as? [String : String] {
                        if let points = polyline["points"] as AnyObject? as? String {
                            encodedRoute = points
                        }
                    }
                }
            }*/
        }
        
        /*
        session.dataTaskWithURL(NSURL(string: urlString)!) {data, response, error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            var encodedRoute: String?
            if let json = NSJSONSerialization.JSONObjectWithData(data, options:nil, error:nil) as? [String:AnyObject] {
                if let routes = json["routes"] as AnyObject? as? [AnyObject] {
                    if let route = routes.first as? [String : AnyObject] {
                        if let polyline = route["overview_polyline"] as AnyObject? as? [String : String] {
                            if let points = polyline["points"] as AnyObject? as? String {
                                encodedRoute = points
                            }
                        }
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                completion(encodedRoute)
            }
            }.resume()*/
    }
}
