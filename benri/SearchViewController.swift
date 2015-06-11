//
//  searchViewController.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 6/7/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import UIKit
import SwiftyJSON

class SearchViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate  {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var surpriseButton: UIButton!
    
    @IBAction func cancelSearch(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(discoverCloseNotificationKey, object: self)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func confirmSearch(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(discoverSearchNotificationKey, object: self)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    let PICKER_TEXT_HEIGHT:CGFloat = 44.0
    let PICKER_TEXT_SIZE:CGFloat = 22.0
    let BUTTON_HEIGHT:CGFloat = 76.0
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    var pickerData:[String] = []
    var const:Const         = Const.sharedInstance
    var activityView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        self.okButton.backgroundColor = UIColor.greenColor()
        //self.okButton.frame = CGRect(x: self.okButton.frame.origin.x, y: self.okButton.frame.origin.y, width: screenSize.width/2, height: BUTTON_HEIGHT)
        
        self.cancelButton.backgroundColor = UIColor.redColor()
        //self.cancelButton.frame = CGRect(x: self.okButton.frame.origin.x, y: self.okButton.frame.origin.y, width: screenSize.width/2, height: BUTTON_HEIGHT)
        self.surpriseButton.backgroundColor = UIColor.whiteColor()
        self.addBlurPage()
        
        self.showTags()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onSuccess(json:AnyObject?) {
        if let json: AnyObject = json {
            let tagJSON = JSON(json)
            for (index: String, itemJSON: JSON) in tagJSON["items"] {
                let tag:JSON = itemJSON[0]
                self.pickerData.append(tag.stringValue)
            }
            activityView.stopAnimating()
            self.pickerView.reloadAllComponents()
        }
    }
    
    func showTags() {
        let tagSVAPI:TagSVAPI = TagSVAPI()
        
        activityView.center = self.view.center
        activityView.startAnimating()
        self.view.addSubview(activityView)
        tagSVAPI.getTags(10,
            successCallback: onSuccess,
            errorCallback: {() -> Void in
                
        })
    }
    
    func addBlurPage() {
        self.view.backgroundColor = UIColor.clearColor()
        
        let blurEffect:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark
        )
        let bluredEffectView = UIVisualEffectView(effect: blurEffect)
        let screenFrame = UIScreen.mainScreen().bounds
        
        bluredEffectView.frame = screenFrame
        self.view.insertSubview(bluredEffectView, atIndex: 1)
        
        
        let vibrancyEffect:UIVibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
        let vibrancyEffectView:UIVisualEffectView = UIVisualEffectView(effect: vibrancyEffect)
        
        vibrancyEffectView.frame = UIScreen.mainScreen().bounds//CGRect(x: screenFrame.width/2, y: 0, width: screenFrame.width/2, height: screenFrame.height)
        vibrancyEffectView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        vibrancyEffectView.contentView.addSubview(pickerView)
        // Add Vibrancy View to Blur View
        bluredEffectView.contentView.insertSubview(vibrancyEffectView, atIndex: 1)
        
        //self.settingSwipeToSearchGesture(button)
    }
    
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView,
        rowHeightForComponent component: Int) -> CGFloat{
            return PICKER_TEXT_HEIGHT
    }
    
    func pickerView(pickerView: UIPickerView,
        viewForRow row: Int,
        forComponent component: Int,
        reusingView view: UIView!) -> UIView{
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            let labelWidth:CGFloat = screenSize.width
            let labelHeight:CGFloat = PICKER_TEXT_HEIGHT
            
            var rect:CGRect = CGRectMake(0, 0, labelWidth, labelHeight)
            var label:UILabel = UILabel(frame: rect)
            label.text = pickerData[row]
            label.font = UIFont(name: label.font.fontName, size: PICKER_TEXT_SIZE)
            
            label.adjustsFontSizeToFitWidth = true
            label.opaque = false
            label.textAlignment = NSTextAlignment.Center
            label.textColor = UIColor.whiteColor()
            label.clipsToBounds = false
            
            return label
    }
    
    func pickerView(pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int){
            const.setConst("search", key: "picker", value: pickerData[row])
            
    }
}