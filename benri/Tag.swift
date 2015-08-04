//
//  Tag.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 7/20/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import Foundation
import SwiftyJSON

class Tag: NSObject {
    var _tagName:String!
    var tagName: String {
        get {
            return _tagName
        }
        set(newName) {
            if count(newName) > 0 {
                _tagName = newName
            } else {
                println("Error tag name must not be empty")
            }
        
        }
    }
    
    var tagImageUrl: NSURL!
    
    override init() {
        super.init()
        tagName = "dummy tag"
        tagImageUrl = NSURL(string: "www.example.com")!
    }
    
    func initByJSON(itemJSON:JSON) {
        
        let tag:JSON = itemJSON[0]
        if let tagName:String = tag.string {
            self.tagName = tagName
            if tagName == "Japanese" {
                if let url = NSURL(string:  "https://pz0tmg.bl3301.livefilestore.com/y3mlHQS_qnvVhQTfRUbHA63VAZ8w9GmaMLJop3jSLd7-F1upYS293W-zHFccpBR4LggB-VzoZqsHVY0oujHK0pPDqA8Lb6ZVTSfqo0tqceihYQjQo_7Rcrd7pb9Om-vSbPbtDBbo_3FAx8C6LoD-3ukLsekq9ZC7nZ5AGCrmsVO1u4/foodiesfeed.com_colorful-sushi-in-a-black-box3.jpg?psid=1") {
                    tagImageUrl = url
                }
            }
           
        }
    }
}