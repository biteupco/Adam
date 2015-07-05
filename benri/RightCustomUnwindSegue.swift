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
        
        if let window:UIWindow = UIApplication.sharedApplication().keyWindow {
            window.insertSubview(destinationVCView, aboveSubview: sourceVCView)
        }
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                sourceVCView.frame         = CGRectOffset(sourceVCView.frame, screenWidth, 0.0)
                destinationVCView.frame    = CGRectOffset(destinationVCView.frame, screenWidth, 0.0)
            }) { (finished) -> Void in
                self.sourceViewController.dismissViewControllerAnimated(false, completion: nil)
        }
    }
}
