//
//  ImageCache.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 3/12/15.
//  Copyright (c) 2015 Benri. All rights reserved.
//

import Foundation
import UIKit

class ImageCache: NSObject {
    // Default is Tokyo
    private var imgCache = NSCache()
    
    override init() {
        
    }
    
    func clearImage() {
        imgCache.removeAllObjects()
    }
    
    func loadImage(imgURL:NSURL) -> UIImage? {
        if let image: AnyObject = imgCache.objectForKey(imgURL) {
            return image as? UIImage
        } else {
            return nil
        }
    }
    
    func cacheImage(imgURL:NSURL?, image:UIImage) {
        if let imageURL = imgURL {
            imgCache.setObject(image, forKey: imageURL)
        }
    }
    
    class var sharedInstance : ImageCache {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : ImageCache? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = ImageCache()
        }
        return Static.instance!
    }
}