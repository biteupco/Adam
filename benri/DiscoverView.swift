//
//  DiscoverView.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 2/7/15.
//  Copyright (c) 2015 Benri. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class DiscoverView: UIView {

    var pickerData:[String] = ["Surprised ME!"]
    var const:Const         = Const.sharedInstance
    var horizonPicker:HorizontalPicker
    
    required init(coder aDecoder: NSCoder) {
        self.horizonPicker = HorizontalPicker(pickerData: self.pickerData)
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.locationInit()
        
        let svapi:TagSVAPI = TagSVAPI()
        
        var activityView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityView.center = self.center
        activityView.startAnimating()
        self.addSubview(activityView)
        
        svapi.getTags(10,
            successCallback: {(somejson)-> Void in
                if let json: AnyObject = somejson {
                    let myJSON = JSON(json)
                    for (index: String, itemJSON: JSON) in myJSON["items"] {
                        let tag:JSON = itemJSON[0]
                        self.pickerData.append(tag.stringValue)
                    }
                    self.horizonPicker.pickerData = self.pickerData
                    self.addSubview(self.horizonPicker.myUIPickerView)
                    self.horizonPicker.createHorizontalPicker()
                    activityView.stopAnimating()
                    
                }
            },
            errorCallback: { () -> Void in
            
            })
    }

    func locationInit(){
        if let locality = const.getConst("location", key: "locality") {
            let locationString = " > " + locality
           // swipeLocationButton.setTitle(locationString, forState: UIControlState.Normal)
           // swipeLocationButton.setTitle(locationString, forState: UIControlState.Selected)
        }
    }

    
    
}