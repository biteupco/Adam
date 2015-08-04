//
//  TagCell.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 7/21/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import UIKit
import Alamofire

extension Alamofire.Request {
    class func imageResponseSerializer() -> Serializer {
        return { request, response, data in
            if data == nil {
                return (nil, nil)
            }
            
            let image = UIImage(data: data!, scale: UIScreen.mainScreen().scale)
            
            return (image, nil)
        }
    }
    
    func responseImage(completionHandler: (NSURLRequest, NSHTTPURLResponse?, UIImage?, NSError?) -> Void) -> Self {
        return response(serializer: Request.imageResponseSerializer(), completionHandler: { (request, response, image, error) in
            completionHandler(request, response, image as? UIImage, error)
        })
    }
}

class TagCell: UITableViewCell {
    
    @IBOutlet weak var tagImageView: UIImageView!
    @IBOutlet weak var tagLabel: UILabel!
    
    var imgCache:ImageCache = ImageCache.sharedInstance
    var menuImageURL: NSURL = NSURL(string: "http://upload.wikimedia.org/wikipedia/commons/a/ad/Kyaraben_panda.jpg")!
    var isImageSet:Bool = false
    
    var request: Alamofire.Request?
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
        self.tagImageView.image = nil
    }
    
    func setLocalImage(tagName:String) {
        if tagName.lowercaseString == "vietnam" {
            self.tagImageView.image  = UIImage(named: "foodiesfeed.com_pho-ga-take-away.jpg")
        }
        else if tagName.lowercaseString == "japanese" {
            self.tagImageView.image  = UIImage(named: "foodiesfeed.com_colorful-sushi-in-a-black-box3.jpg")
        }
        else if tagName.lowercaseString == "italian" {
            self.tagImageView.image  = UIImage(named: "foodiesfeed.com_fresh-pasta-dill-vegetables.jpg")
        }
        
    }
    
    func setImageByURL(imgURL: NSURL) {
        self.tagImageView.image = nil
        
        if let image = self.imgCache.loadImage(imgURL) {
            self.tagImageView.image = image
        } else {
            self.request = Alamofire.request(.GET, imgURL).validate(contentType: ["image/*"]).responseImage() {
                (request, _, image, error) in
                if error == nil && image != nil {
                    self.imgCache.cacheImage(request.URL, image: image!)
                    self.tagImageView.image = image
                } else {
                    
                }
            }
        }
    }
    
    func setTagInfo(tagObj:Tag) {
        self.tagLabel.text = tagObj.tagName
        self.setLocalImage(tagObj.tagName)
        //self.setImageByURL(tagObj.tagImageUrl)
    }
}
