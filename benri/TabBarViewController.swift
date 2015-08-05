//
//  TabBarViewController.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 7/5/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // FIXME
        if self.topLayoutGuide.length == 0.0 {
            for constraint in self.view!.constraints() as! [NSLayoutConstraint] {
                constraint.constant = 20.0
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

    override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
        if identifier == "backFromLocationToTag" || identifier == "didSelectLocation"{
            return DownCustomUnwindSegue(identifier: identifier, source: fromViewController, destination: toViewController)
        } else {
            let segue = RightCustomUnwindSegue(identifier: identifier, source: fromViewController, destination: toViewController)
            return segue
        }
    }
    
    override func viewControllerForUnwindSegueAction(action: Selector, fromViewController: UIViewController, withSender sender: AnyObject?) -> UIViewController? {
        var resultVC = self.selectedViewController?.viewControllerForUnwindSegueAction(action, fromViewController: fromViewController, withSender: sender)
        return resultVC
    }
}
