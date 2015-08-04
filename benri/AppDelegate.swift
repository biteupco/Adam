//
//  AppDelegate.swift
//  benri
//
//  Created by Kittikorn Ariyasuk on 4/26/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import UIKit
import Mixpanel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let font = UIFont(name: "Lobster-Regular", size: 20)
        if let font = font {
            UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : font , NSForegroundColorAttributeName : UIColor(
                red:  CGFloat(255) / 255.0,
                green: CGFloat(119) / 255.0,
                blue: CGFloat(78) / 255.0,
                alpha: CGFloat(1.0)
            )]
        }
        
        if let path = NSBundle.mainBundle().pathForResource("APISetting", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
                if let mixPanel = dict["Mixpanel"] as? String {
                    var mixPanelInstance:Mixpanel = Mixpanel.sharedInstanceWithToken(mixPanel)
                }
                if let googleMapAPI = dict["GoogleMap"] as? String{
                    GMSServices.provideAPIKey(googleMapAPI)
                }
            }
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

