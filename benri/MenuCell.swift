//
//  MenuCell.swift
//  benri
//
//  Created by Kittikorn Ariyasuk on 5/1/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import UIKit
import Alamofire

class MenuCell: UITableViewCell {
    
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var menuNameLabel: UILabel!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var distantLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var imgProgressView: UIProgressView!
    @IBOutlet weak var likeButton: UIButton!
    
    var locationService = LocationService.sharedInstance
    var imgCache:ImageCache = ImageCache.sharedInstance
    
    var likeItem:LikeItemManager = LikeItemManager.sharedInstance
    
    var menu:Menu!
    var restaurant:Restaurant!
    var menuName: String = ""
    var storeName: String = ""
    var menuImageURL: NSURL = NSURL(string: "http://upload.wikimedia.org/wikipedia/commons/a/ad/Kyaraben_panda.jpg")!
    var price: String = ""
    var distant: String = ""
    var address: String = ""
    var isImageSet:Bool = false
    
    var request: Alamofire.Request?
        
    @IBAction func onClickLike(sender: AnyObject) {
        println("Like " + self.menuName)
        likeItem.addItem(self.menu.menuID, menu: self.menu, resID: self.restaurant.id, restaurant: self.restaurant)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.menuNameLabel.text = ""
        self.storeNameLabel.text = ""
        self.menuImageView.image = nil
        self.priceLabel.text = ""
        self.distantLabel.text = ""
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func resizePriceLabelFrame(priceText: String){
        //Calculate the expected size based on the font and linebreak mode of your label
        var maximumLabelSize: CGSize = CGSizeMake(320, 60)
        let myPriceText: NSString = priceText as NSString
        let expectedLabelSize: CGSize = myPriceText.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(17.0)])
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        
        var newFrame: CGRect = self.priceLabel.frame
        newFrame.size.width = round(expectedLabelSize.width)
        newFrame.origin.x   = screenWidth - newFrame.size.width
        newFrame.size.height = round(expectedLabelSize.height) + 500
        
        self.priceLabel.text = priceText
        self.priceLabel.frame = newFrame
        self.priceLabel.textAlignment = NSTextAlignment.Center
        
    }
    
    func _setPriceLabel(price: Float, currencyCode:String){
        var const:Const = Const.sharedInstance
        var priceText = ""
        if price % 1 == 0 {
            priceText = String(format: "%.0f", price)
        }
        else {
            priceText = String(format: "%.2f", price)
        }
        
        let currencySymbol = CurrencyConverter.codeToSymbol(currencyCode)
        priceText = " " + currencySymbol + " " + priceText + "  "
        self.priceLabel.text = priceText
    }
    
    func _getPriceLabel() -> String? {
        return self.priceLabel.text
    }
    
    func _setMenuNameLabel(name: String) {
        self.menuName = name
        self.menuNameLabel.text = name
    }
    
    func _getMenuNameLabel() ->String? {
        return self.menuNameLabel.text
    }
    
    func _setStoreNameLabel(name: String) {
        self.storeNameLabel.text = name
    }
    
    func _getStoreNameLabel() ->String? {
        return self.storeNameLabel.text
    }
    
    func updateDistantLabelVisible() {
        if let isLocationEnable:AnyObject = NSUserDefaults.standardUserDefaults().valueForKey("isLocationEnable") {
            self.distantLabel.hidden = !(isLocationEnable as! Bool)
        } else {
            self.distantLabel.hidden = false
        }
    }
    
    func _setDistantLabel(distance: Double) {
        var formatter : String = ""
        if distance < 1 {
            let meterD = Int(distance * 1000)
            formatter = String(format: "%d m", meterD)
        } else {
            formatter = String(format: "%.02f km", distance)
        }
        self.distantLabel.text = formatter
        self.updateDistantLabelVisible()
    }
    
    func _getDistanceLabel() ->String? {
        return self.distantLabel.text
    }
    
    func _setImage(image: UIImage) {
        self.menuImageView.image = image
    }
    
    func setImageByName(imgName: String) {
        self.menuImageView.image = UIImage(named: imgName)
    }
    
    func updateImgURL(imgURL: NSURL) {
        self.menuImageURL = imgURL
    }
    
    func setImageByURL(imgURL: NSURL) {
        self.menuImageView.image = nil
        
        if let image = self.imgCache.loadImage(imgURL) {
            
            self.menuImageView.image = image
            self.imgProgressView.hidden = true
        } else {
            
            self.menuImageView.image = UIImage(named: "placeholder")
            self.request = Alamofire.request(.GET, imgURL).validate(contentType: ["image/*"]).responseImage() {
                (request, _, image, error) in
                if error == nil && image != nil {
                    self.imgCache.cacheImage(request.URL, image: image!)
                    self.menuImageView.image = image
                } else {
                }
            }
        }
    }
    
    func getImageURL() -> NSURL {
        return self.menuImageURL
    }
    
    func _setAddress(address:String) {
        self.address = address
    }
    
    func _getAddress() -> String?{
        return self.address
    }
    func setMenu(menu:Menu, restaurant:Restaurant) {
        let storeDistance = self.locationService.getDistanceFrom(restaurant.location)
        self.menu = menu
        self.restaurant = restaurant
        
        self._setDistantLabel(storeDistance)
        self._setMenuNameLabel(menu.menuName)
        self._setStoreNameLabel(restaurant.name)
        self._setPriceLabel(menu.price, currencyCode: menu.currency)
        self._setAddress(restaurant.address)
    }

}