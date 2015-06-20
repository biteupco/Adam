//
//  PageContentViewController.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 6/19/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import UIKit

class PageContentViewController: UIViewController {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    var pageIndex: Int!
    var titleText: String!
    var imageFile: String!
    var detailText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imgView.image = UIImage(named: imageFile)
        self.label.text = self.titleText
        self.textView.text = NSLocalizedString(detailText, comment: "Tutorial text")
        self.view.backgroundColor = UIColor(red: 252.0/255.0, green: 119.0/255.0, blue: 7.0/255.0, alpha: 1.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
