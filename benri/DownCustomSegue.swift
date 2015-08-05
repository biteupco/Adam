//
//  TopCustomSegue.swift
//  adam
//
//  Created by ariyasuk-k on 8/5/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import UIKit

class DownCustomSegue: UIStoryboardSegue {
    
    override func perform() {
        var sourceVCView = self.sourceViewController.view as UIView
        var destinationVCView = self.destinationViewController.view as UIView
        
        if let tabBarController = self.sourceViewController.tabBarController as UITabBarController? {
            sourceVCView = tabBarController.view as UIView
        }
        
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        
        destinationVCView.frame = CGRectMake(0.0, -screenHeight, screenWidth, screenHeight)
        
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(destinationVCView, aboveSubview: sourceVCView)
        
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                sourceVCView.frame         = CGRectOffset(sourceVCView.frame, 0.0, screenHeight)
                destinationVCView.frame    = CGRectOffset(destinationVCView.frame, 0.0, screenHeight)
            }) { (finished) -> Void in
                self.sourceViewController.tabBarController!!.presentViewController(self.destinationViewController as! UIViewController, animated:false, completion: nil)
        }
        
    }
}
