//
//  TopCustomUnwindSegue.swift
//  adam
//
//  Created by ariyasuk-k on 8/5/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import UIKit

class DownCustomUnwindSegue: UIStoryboardSegue {
    override func perform() {
        let id = self.identifier
        var sourceVCView:UIView = self.sourceViewController.view as UIView
        var destinationVCView:UIView = self.destinationViewController.view as UIView
        
        if let tabBarController = self.destinationViewController.tabBarController as UITabBarController? {
           destinationVCView = tabBarController.view as UIView
        }
        
        var screenWidth = UIScreen.mainScreen().bounds.size.width
        var screenHeight = UIScreen.mainScreen().bounds.size.height
        
        if let window:UIWindow = UIApplication.sharedApplication().keyWindow {
            window.insertSubview(destinationVCView, aboveSubview: sourceVCView)
        }
        /*
        
        Currently buggy:
        Apparently topLayoutGuide went to 0 after animation? Have to change height manually
        
        */
        for constraint in self.destinationViewController.view!.constraints() as! [NSLayoutConstraint] {
            
            if constraint.firstItem === self.destinationViewController.topLayoutGuide
                && constraint.firstAttribute == .Height
                && constraint.secondItem == nil
                && constraint.constant == 0 {
                    constraint.constant = 20.0
            }
        }
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                sourceVCView.frame         = CGRectOffset(sourceVCView.frame, 0.0, -screenHeight)
                destinationVCView.frame    = CGRectOffset(destinationVCView.frame, 0.0, -screenHeight)
            }) { (finished) -> Void in
                if (finished) {
                   self.sourceViewController.dismissViewControllerAnimated(false, completion: nil)
                }
        }
    }
}
