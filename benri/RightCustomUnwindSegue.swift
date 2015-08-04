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
        let sourceVCView = self.sourceViewController.view as UIView!
        let destinationVCView = self.destinationViewController.view as UIView!
        
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        
        //destinationVCView.frame = CGRectMake(-screenWidth, 0.0, screenWidth, screenHeight);
        
        if let window:UIWindow = UIApplication.sharedApplication().keyWindow {
            if let matabBon = self.destinationViewController.tabBarController {
                //window.insertSubview(matabBon!.view, aboveSubview: sourceVCView)
                //window.insertSubview(destinationVCView, belowSubview: matabBon!.view)
            }
            window.insertSubview(destinationVCView, aboveSubview: sourceVCView)
            //window.addSubview(destinationVCView)
            //window.insertSubview(destinationVCView, belowSubview: sourceVCView)
        }
        println(destinationVCView.frame)
        UIView.animateWithDuration(5.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                sourceVCView.frame         = CGRectOffset(sourceVCView.frame, screenWidth, 0.0)
                destinationVCView.frame    = CGRectOffset(destinationVCView.frame, 200, 0.0)
                
            }) { (finished) -> Void in
                if (finished) {
                    destinationVCView.removeFromSuperview()
                    self.sourceViewController.dismissViewControllerAnimated(false, completion: nil)
                   // self.destinationViewController.removeFromSuperview()
                    if let tabBarCon = self.destinationViewController.tabBarController {
                        tabBarCon?.selectedIndex = 0
                    }
                }
        }
    }
}
