//
//  DiscoverViewController.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 2/7/15.
//  Copyright (c) 2015 Benri. All rights reserved.
//

import Foundation
import UIKit

class DiscoverViewConroller : UIViewController {
    
    @IBOutlet var myView: DiscoverView!
    @IBOutlet weak var myPickerView: UIPickerView!
    
    @IBAction func onCancelClick(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(discoverCloseNotificationKey, object: self)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    let startPosition:CGPoint = CGPoint(x: 0, y: 500)
    let targetPosition:CGPoint = CGPoint(x: 0, y: 0)
    var const:Const         = Const.sharedInstance
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.view.frame.origin = self.startPosition
        self.addBlurPage()
        UIView.animateWithDuration(0.5, animations: {
            self.view.frame.origin = self.targetPosition
            }
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addBlurPage() {
        self.view.backgroundColor = UIColor.clearColor()
        
        let blurEffect:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let bluredEffectView = UIVisualEffectView(effect: blurEffect)
        let screenFrame = UIScreen.mainScreen().bounds
        
        bluredEffectView.frame = screenFrame
        self.view.insertSubview(bluredEffectView, atIndex: 1)
        
        
        let vibrancyEffect:UIVibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
        let vibrancyEffectView:UIVisualEffectView = UIVisualEffectView(effect: vibrancyEffect)
        let swipeLabelPostion = CGPoint(x: 0, y: screenFrame.height - 88)
        
        vibrancyEffectView.frame = CGRect(x: 0, y: 0, width: screenFrame.width, height: screenFrame.height)
        vibrancyEffectView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // Add Label to Vibrancy View
        
        let button   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.frame = CGRectMake(swipeLabelPostion.x, swipeLabelPostion.y, screenFrame.width, 88)
        button.backgroundColor = UIColor.clearColor()
        button.setTitle("Search for Your Selection", forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont(name: "Helvetica", size: 22)
        button.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        var swipeLabel:UILabel = UILabel(frame: CGRect(x: swipeLabelPostion.x, y: swipeLabelPostion.y, width: screenFrame.width, height: 88))
        
        vibrancyEffectView.contentView.addSubview(swipeLabel)
        vibrancyEffectView.contentView.addSubview(button)
        // Add Vibrancy View to Blur View
        bluredEffectView.contentView.insertSubview(vibrancyEffectView, atIndex: 1)
        
        self.settingSwipeToSearchGesture(button)
    }
    
    func slideToRightWithGestureRecognizer() {
        NSNotificationCenter.defaultCenter().postNotificationName(discoverSearchNotificationKey, object: self)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    func settingSwipeToSearchGesture(swipeArea:UIView) {
        var swipeRightSearch: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "slideToRightWithGestureRecognizer")
        swipeRightSearch.direction = UISwipeGestureRecognizerDirection.Right
        swipeArea.addGestureRecognizer(swipeRightSearch)

    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func buttonAction(sender:UIButton!)
    {
        NSNotificationCenter.defaultCenter().postNotificationName(discoverSearchNotificationKey, object: self)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
}