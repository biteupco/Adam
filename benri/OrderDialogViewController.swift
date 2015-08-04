//
//  OrderDialogViewController.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 7/11/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import UIKit

class OrderDialogViewController: UIViewController {

    @IBOutlet var dialogView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenSize = UIScreen.mainScreen().bounds
        self.view.frame = CGRect(x: 0.0, y: 0.0, width: screenSize.width, height: screenSize.height)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
