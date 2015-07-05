//
//  LoadingIndicator.swift
//  
//
//  Created by Kittikorn Ariyasuk on 6/30/15.
//
//

import Foundation

class LoadingIndicator {
    
    let imageFile = ["gobblLoading_1","gobblLoading_2","gobblLoading_3","gobblLoading_4","gobblLoading_5","gobblLoading_6","gobblLoading_7","gobblLoading_8","gobblLoading_9","gobblLoading_10","gobblLoading_11","gobblLoading_12"]
    
    var statusImage:UIImage!
    var activityImageView:UIImageView!
    
    init() {
        statusImage = UIImage(named: "gobblLoading_1")
        activityImageView = UIImageView(image: statusImage)
        var animationImages:[UIImage] = []
        for imageNamed in imageFile {
            if let img = UIImage(named: imageNamed) {
                animationImages.append(img)
            }
        }
        
        activityImageView.animationImages = animationImages
            
        
        println(activityImageView.animationImages)
        activityImageView.animationDuration = 0.8
        
        var bounds = UIScreen.mainScreen().bounds
        var width = bounds.size.width
        var height = bounds.size.height
        activityImageView.frame = CGRectMake((width / 2) - (statusImage.size.width / 2),  (height/2)-(statusImage.size.height/2), statusImage.size.width, statusImage.size.height)
        
        /*
        CGRectMake(self.view.frame.size.width/2
        -statusImage.size.width/2,
        self.view.frame.size.height/2
        -statusImage.size.height/2,
        statusImage.size.width,
        statusImage.size.height);*/

    }
    
    /*UIImageView *activityImageView = [[UIImageView alloc]
    initWithImage:statusImage];
    
    
    //Add more images which will be used for the animation
    activityImageView.animationImages = [NSArray arrayWithObjects:
    [UIImage imageNamed:@"status1.png"],
    [UIImage imageNamed:@"status2.png"],
    [UIImage imageNamed:@"status3.png"],
    [UIImage imageNamed:@"status4.png"],
    [UIImage imageNamed:@"status5.png"],
    [UIImage imageNamed:@"status6.png"],
    [UIImage imageNamed:@"status7.png"],
    [UIImage imageNamed:@"status8.png"],
    nil];
    */
    
    //Set the duration of the animation (play with it
    //until it looks nice for you)
    
    
    
    //Start the animation
    //[activityImageView startAnimating];
    
    
    //Add your custom activity indicator to your current view
    //[self.view addSubview:activityImageView];
    
    func animate() {
    
    }
    class var sharedInstance : LoadingIndicator {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : LoadingIndicator? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = LoadingIndicator()
        }
        return Static.instance!
    }
}