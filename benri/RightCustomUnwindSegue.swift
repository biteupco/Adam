//
//  RightCustomUnwindSegue.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 7/5/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import UIKit

class RightCustomUnwindSegue: UIStoryboardSegue {
    
    override func perform() {
        let id = self.identifier
        var sourceVCView:UIView = self.sourceViewController.view as UIView
        var destinationVCView:UIView = self.destinationViewController.view as UIView
        
        if let tabBarController = self.destinationViewController.tabBarController as UITabBarController? {
            destinationVCView = tabBarController.view as UIView
        }
        
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        
        if let window:UIWindow = UIApplication.sharedApplication().keyWindow {
            window.insertSubview(destinationVCView, aboveSubview: sourceVCView)
        }
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                sourceVCView.frame         = CGRectOffset(sourceVCView.frame, screenWidth, 0.0)
                destinationVCView.frame    = CGRectOffset(destinationVCView.frame, screenWidth, 0.0)
                
            }) { (finished) -> Void in
                if (finished) {
                    self.sourceViewController.dismissViewControllerAnimated(false, completion: nil)
                }
        }
    }
}
