//
//  HorizontalPicker.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 2/18/15.
//  Copyright (c) 2015 Benri. All rights reserved.
//

import Foundation
import UIKit

class HorizontalPicker: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {

    var pickerHeight : CGFloat = 216.0
    var pickerWidth  : CGFloat = 26.0
    var pickerXPos   : CGFloat = 147.0
    var pickerYPos   : CGFloat = 40.0
    var pickerScale  : CGFloat = 1.481
    
    var const:Const = Const.sharedInstance
    
    var myUIPickerView : UIPickerView
    var pickerData : [String] = []
    
    init(pickerData:[String]) {
        self.pickerData = pickerData
        self.myUIPickerView = UIPickerView(frame: CGRectMake(0, 150, 320, 216))
    }
    
    func createHorizontalPicker() {
        self.myUIPickerView.delegate = self
        self.myUIPickerView.dataSource = self
        
        self.flipHorizontal()
    }
    
    func flipHorizontal() {
        let screenRect:CGRect = UIScreen.mainScreen().bounds
        let screenWidth:CGFloat = screenRect.size.width
        
        
        self.myUIPickerView.showsSelectionIndicator = false
        self.myUIPickerView.hidden = false
        
        self.myUIPickerView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        self.myUIPickerView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        
        self.myUIPickerView.frame = CGRectMake(pickerXPos, pickerYPos, pickerWidth, pickerHeight)
        self.myUIPickerView.alpha = 1.0
        
        var t0:CGAffineTransform = CGAffineTransformMakeTranslation (0, self.myUIPickerView.bounds.size.height/2)
        var s0:CGAffineTransform = CGAffineTransformMakeScale(pickerScale, pickerScale)
        var t1:CGAffineTransform = CGAffineTransformMakeTranslation (0, -self.myUIPickerView.bounds.size.height/2)
        
        self.myUIPickerView.transform = CGAffineTransformConcat(t0, CGAffineTransformConcat(s0, t1))
        self.myUIPickerView.transform = CGAffineTransformRotate(self.myUIPickerView.transform, CGFloat(-M_PI/2))
        
        self.myUIPickerView.reloadAllComponents()
        
        self.rotateAnimation(1.4, index: 1)
    }
    
    func rotateAnimation(delay:Double, index:Int) {
        UIView.animateWithDuration(delay, animations: {
            self.myUIPickerView.alpha = 1.0
            },
            completion: {
                (value:Bool) in
                self.myUIPickerView.selectRow(index, inComponent: 0, animated: true)
                self.const.setConst("search", key: "picker", value: self.pickerData[index])
        })
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
            return pickerHeight
    }
    
    func pickerView(pickerView: UIPickerView,
        viewForRow row: Int,
        forComponent component: Int,
        reusingView view: UIView!) -> UIView{
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            let labelWidth:CGFloat = screenSize.width * 0.65
            let labelHeight:CGFloat = 216.0
            
            var rect:CGRect = CGRectMake(0, 0, labelWidth, labelHeight)
            var label:UILabel = UILabel(frame: rect)
            label.text = pickerData[row]
            label.adjustsFontSizeToFitWidth = true
            label.opaque = false
            label.textAlignment = NSTextAlignment.Center
            label.textColor = UIColor.whiteColor()
            label.clipsToBounds = false
            label.transform = CGAffineTransformRotate(label.transform, CGFloat(M_PI/2))
            return label
    }
    
    func pickerView(pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int){
            const.setConst("search", key: "picker", value: pickerData[row])
            
    }
}