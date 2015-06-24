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

class ProfileViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var detailTable: UITableView!
    
    var loginView:FBSDKLoginButton!
    
    var userDefault:NSUserDefaults!
    var imageCache:ImageCache!
    var request: Alamofire.Request?
    
    var fullName:String!
    var email:String!
    var profileImageURLString:String!
    
    
    @IBAction func logOut(sender: AnyObject) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        print("log out")
        self.loginView.hidden = false
        self.hideProfilePage()
        self.view.setNeedsDisplay()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.userDefault = NSUserDefaults.standardUserDefaults()
        self.imageCache = ImageCache.sharedInstance
        
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
                if let myEmail = self.userDefault.objectForKey("email") as? String {
                    self.emailLabel.text = myEmail
                } else {
                    let myEmail = result.valueForKey("email") as! String
                    self.userDefault.setObject(myEmail, forKey: "email")
                }
                
                // Name
                if let myName = self.userDefault.objectForKey("userName") as? String {
                   self.nameLabel.text = myName
                } else {
                    let myName = result.valueForKey("name") as! String
                    self.userDefault.setObject(myName, forKey: "userName")
                }
                
                
                // Profile Image
                self.request?.cancel()
                if let imageURL = self.userDefault.objectForKey("profileImgURL") as? NSURL {
                    if let profileImage = self.imageCache.loadImage(imageURL) {
                        self.imageView.image = profileImage
                    } else {
                        
                        self.request = Alamofire.request(.GET, imageURL.absoluteString!).validate(contentType: ["image/*"]).responseImage() {
                            (request, _, image, error) in
                            if error == nil && image != nil {
                                self.imageCache.cacheImage(request.URL, image: image!)
                                self.imageView.image = image
                            }
                        }
                    }
                } else {
                    let fbID = result.valueForKey("id") as! String
                    let profileImgURL = String(format: "https://graph.facebook.com/%@/picture?type=large", fbID)
                    self.userDefault.setObject(profileImgURL, forKey: "profileImgURL")
                    
                    self.request = Alamofire.request(.GET, profileImgURL).validate(contentType: ["image/*"]).responseImage() {
                        (request, _, image, error) in
                        if error == nil && image != nil {
                            self.imageCache.cacheImage(request.URL, image: image!)
                            self.imageView.image = image
                            
                            self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
                            self.imageView.clipsToBounds = true
                        }
                    }
                }
                self.showProfilePage()
                self.view.setNeedsDisplay()
                self.userDefault.synchronize()
                
                println("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                println("User Name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as! NSString
                println("User Email is: \(userEmail)")
                
                if FBSDKAccessToken.currentAccessToken() != nil {
                    println(FBSDKAccessToken.currentAccessToken().tokenString)
                }
            }
        })
    }
    
    private func showLoginButton() {

    }
    
    private func showProfilePage() {
        self.upperView.hidden = false
        self.detailTable.hidden = false
        self.logOutButton.hidden = false
    }
    
    private func hideProfilePage() {
        self.upperView.hidden = true
        self.detailTable.hidden = true
        self.logOutButton.hidden = true
    }
}