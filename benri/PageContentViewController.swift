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
    @IBOutlet weak var loginButton: FBSDKLoginButton! = FBSDKLoginButton()
    
    @IBAction func SkipLogin(sender: AnyObject) {
        delegate!.didSkipSignIn()
    }
    
    
    var userDefault:NSUserDefaults!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            if self.loginButton != nil {
                self.loginButton.hidden = true
                self.returnUserData()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userDefault = NSUserDefaults.standardUserDefaults()
        
        self.imgView.image = UIImage(named: imageFile)
        self.label.text = self.titleText
        self.view.backgroundColor = UIColor(red: 252.0/255.0, green: 119.0/255.0, blue: 7.0/255.0, alpha: 1.0)
        
        
        if pageIndex == 5 {
            self.textView.hidden = true
            self.loginTextView.text = NSLocalizedString(detailText, comment: "Tutorial text")
            self.loginButton.readPermissions = ["public_profile", "email", "user_friends"]
            self.loginButton.delegate = self
            self.loginButton.hidden = false
            
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
            // Was autheticated
            self.loginButton.hidden = true
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
            var profileImgURL:String!
            
            if ((error) != nil) {
                // Process error
                println("Error: \(error)")
            }
            else {
                fbID = result.valueForKey("id") as! String
                email = result.valueForKey("email") as! String
                token = FBSDKAccessToken.currentAccessToken().tokenString
                userName = result.valueForKey("name") as! String
                profileImgURL = String(format: "https://graph.facebook.com/%@/picture?type=large", fbID)
                
                let api:LoginAPI = LoginAPI()
                api.loginByFacebook(token,
                    fid: fbID,
                    email: email,
                    successCallback: { (json) -> Void in
                        self.delegate.didLoginFacebook(email, token:token, profileImgURL: profileImgURL, userName: userName)
                    }, errorCallback: { () -> Void in
                        
                })
            }
        })
    }
}
