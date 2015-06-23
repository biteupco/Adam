//
//  MenuDetailViewController.swift
//  adam
//
//  Created by ariyasuk-k on 6/23/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import UIKit
import Alamofire

class MenuDetailViewController: UIViewController {
    
    var menu:Menu!
    var restaurant:Restaurant!
    
    var imageCache:ImageCache = ImageCache.sharedInstance
    
    var request: Alamofire.Request?
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var restaurantLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.restaurantLabel.text = restaurant.name
        
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
        var mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        let mapSnapshot = mapView.snapshotViewAfterScreenUpdates(true)
        self.view.addSubview(mapView)
        
        
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
