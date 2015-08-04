//
//  ProfileViewController.swift
//  benri
//
//  Created by ariyasuk-k on 5/22/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

extension UIImageView {
    func setRoundImage() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
}

class ProfileViewController: UIViewController, FBSDKLoginButtonDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var detailTable: UITableView!
    
    
    @IBAction func TutorialReset(sender: AnyObject) {
        var userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setBool(false, forKey: "didFinishedTutorial")
        if !self.logOutButton.hidden {
            self.logOut(self)
        }
    }
    
    var loginView:FBSDKLoginButton!
    
    var userDefault:NSUserDefaults!
    var imageCache:ImageCache!
    var request: Alamofire.Request?
    
    var fullName:String!
    var email:String!
    var profileImageURLString:String!
    
    
    @IBAction func logOut(sender: AnyObject) {
        var alert:UIAlertView = UIAlertView(title: "Confirm log out", message: "Are you sure you want to log out?", delegate: self, cancelButtonTitle: "cancel", otherButtonTitles: "yes")
        alert.show()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.userDefault = NSUserDefaults.standardUserDefaults()
        self.imageCache = ImageCache.sharedInstance
        
        // For now  hide the setting table
        self.detailTable.hidden = true
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            // User is already logged in, do work such as go to next view controller.
            
            // Or Show Logout Button
            self.loginView = FBSDKLoginButton()
            self.view.addSubview(loginView)
            self.loginView.center = self.view.center
            self.loginView.readPermissions = ["public_profile", "email", "user_friends"]
            self.loginView.delegate = self
            self.loginView.hidden = true
            self.returnUserData()

        }
        else {
            self.loginView = FBSDKLoginButton()
            self.view.addSubview(loginView)
            self.loginView.center = self.view.center
            self.loginView.readPermissions = ["public_profile", "email", "user_friends"]
            self.loginView.delegate = self
            self.hideProfilePage()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if ((error) != nil){
            
        }
        else if result.isCancelled {
        
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                // Do work
            }
            self.returnUserData()
            self.loginView.hidden = true
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User Logged Out")
    }
    
    func returnUserData() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                println("Error: \(error)")
            }
            else
            {
                self.userDefault = NSUserDefaults.standardUserDefaults()
                
                // Email
                let myEmail:String = result.valueForKey("email") as! String
                self.userDefault.setObject(myEmail, forKey: "email")
                
                
                // Name
                let myName:String = result.valueForKey("name") as! String
                self.userDefault.setObject(myName, forKey: "userName")
                
                // Profile Image
                let fbID:String = result.valueForKey("id") as! String
                let profileImgURL = String(format: "https://graph.facebook.com/%@/picture?type=large", fbID)
                self.userDefault.setObject(profileImgURL, forKey: "profileImgURL")
                self.userDefault.synchronize()
                    
                self.setupProfileView()
                self.view.setNeedsDisplay()
                
                println("fetched user: \(result)")
                
                if FBSDKAccessToken.currentAccessToken() != nil {
                    let api:LoginAPI = LoginAPI()
                    api.loginByFacebook(FBSDKAccessToken.currentAccessToken().tokenString,
                        fid: fbID,
                        email: myEmail,
                        successCallback: { (json) -> Void in
                            
                    }, errorCallback: { () -> Void in
                        
                    })
                }
            }
        })
    }
    
    private func showLoginButton() {

    }
    
    private func setupProfileView() {
        // Hide detail for now
        self.detailTable.hidden = true
        
        self.userDefault = NSUserDefaults.standardUserDefaults()
        
        // Email
        if let myEmail = self.userDefault.objectForKey("email") as? String {
            self.emailLabel.text = myEmail
        }
        
        // Name
        if let myName = self.userDefault.objectForKey("userName") as? String {
            self.nameLabel.text = myName
        }
        
        self.request?.cancel()
        // Profile Image
        if let imageURL = self.userDefault.objectForKey("profileImgURL") as? String {
            if let profileImage = self.imageCache.loadImage(NSURL(string: imageURL)!) {
                self.imageView.image = profileImage
                self.imageView.setRoundImage()
            } else {
                
                self.request = Alamofire.request(.GET, imageURL).validate(contentType: ["image/*"]).responseImage() {
                    (request, _, image, error) in
                    if error == nil && image != nil {
                        self.imageCache.cacheImage(request.URL, image: image!)
                        self.imageView.image = image
                        self.imageView.setRoundImage()
                        
                    }
                }
            }
        }
        
        self.showProfilePage()
    }
    
    private func showProfilePage() {
        self.upperView.hidden = false
        //self.detailTable.hidden = false
        self.logOutButton.hidden = false
    }
    
    private func hideProfilePage() {
        self.upperView.hidden = true
        self.detailTable.hidden = true
        self.logOutButton.hidden = true
    }
    // MARK: Alertview delegate
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if (buttonIndex == 0) {
            
        }
        else if (buttonIndex == 1) {
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            
            self.userDefault = NSUserDefaults.standardUserDefaults()
            
            self.userDefault.removeObjectForKey("email")
            self.userDefault.removeObjectForKey("userName")
            self.userDefault.removeObjectForKey("profileImgURL")
            self.userDefault.synchronize()
            
            self.loginView.hidden = false
            self.hideProfilePage()
            self.view.setNeedsDisplay()
        }

    }
}