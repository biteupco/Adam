//
//  PageContentViewController.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 6/19/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import UIKit

class PageContentViewController: UIViewController, FBSDKLoginButtonDelegate {

    var pageIndex: Int!
    var titleText: String!
    var imageFile: String!
    var detailText: String!
    var delegate: TutorialDelegate!
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var loginTextView: UITextView!
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
    @IBAction func SkipLogin(sender: AnyObject) {
        delegate!.didSkipSignIn()
    }
    
    
    var userDefault:NSUserDefaults!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userDefault = NSUserDefaults.standardUserDefaults()
        
        self.imgView.image = UIImage(named: imageFile)
        self.label.text = self.titleText
        self.view.backgroundColor = UIColor(red: 252.0/255.0, green: 119.0/255.0, blue: 7.0/255.0, alpha: 1.0)
        if self.pageIndex == 5 {
            self.textView.hidden = true
            self.loginTextView.text = NSLocalizedString(detailText, comment: "Tutorial text")
            
            self.loginButton = FBSDKLoginButton()
            self.loginButton.readPermissions = ["public_profile", "email", "user_friends"]
            self.loginButton.delegate = self
            
        } else {
            self.skipButton.hidden = true
            self.loginTextView.hidden = true
            self.loginButton.hidden = true
            self.textView.text = NSLocalizedString(detailText, comment: "Tutorial text")
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        println("User Logged In")
        
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
            // Skip Tutorial
            userDefault.setBool(true, forKey: "didFinishedTutorial")
            
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
                println("Email permission")
            }
            if result.grantedPermissions.contains("public_profile") {
                
                println("public_profile permission")
            }
            if result.grantedPermissions.contains("user_friends") {
                
                println("user_friends permission")
            }
            userDefault.setBool(true, forKey: "didFinishedTutorial")
            self.returnUserData()
        }
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User Logged Out")
    }
    
    func returnUserData() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            var token:String!
            var email:String!
            var fbID:String!
            var userName:String!
            
            if ((error) != nil) {
                // Process error
                println("Error: \(error)")
            }
            else {
                fbID = result.valueForKey("id") as! String
                email = result.valueForKey("email") as! String
                token = FBSDKAccessToken.currentAccessToken().tokenString
                userName = result.valueForKey("name") as! String
            }
            self.delegate.didLoginFacebook(email, token:token, id: fbID, userName: userName)
        })
    }
}
