//
//  PromptViewController.swift
//  adam
//
//  Created by Kittikorn Ariyasuk on 6/18/15.
//  Copyright (c) 2015 gobbl. All rights reserved.
//

import UIKit

class TutorialViewController:UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pageViewController: UIPageViewController!
    var pageTitles: [String]!
    var pageImages: [String]!
    var pageDetail: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Go to Tutorial
        self.view.backgroundColor = UIColor(red: 252.0/255.0, green: 119.0/255.0, blue: 7.0/255.0, alpha: 1.0)
        
        self.pageTitles = ["Gobbl", "Food Search", "Store Locate", "Collect & Pay", "Eat & Log", "Login"]
        self.pageImages = ["GobblTutorial", "Tutorial1", "MapTutorial", "Tutorial1", "Tutorial1", "GobblTutorial"]
        self.pageDetail = ["TutorialString_1", "TutorialString_2", "TutorialString_3", "TutorialString_4", "TutorialString_5", "TutorialString_6", ]
        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        var startVC = self.viewControllerAtIndex(0) as PageContentViewController
        var viewControllers: [UIViewController] = [startVC]
        
        self.pageViewController.setViewControllers(viewControllers, direction: .Forward, animated: true, completion: nil)
        
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.size.height - 40)
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        
        self.pageViewController.didMoveToParentViewController(self)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func viewControllerAtIndex(index : Int) -> PageContentViewController {
        if((self.pageTitles.count == 0) || (index >= self.pageTitles.count)) {
            return PageContentViewController()
        }
        
        var pageContentVC: PageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageContentViewController") as! PageContentViewController
        
        pageContentVC.imageFile = self.pageImages[index]
        pageContentVC.titleText = self.pageTitles[index]
        pageContentVC.detailText = self.pageDetail[index]
        pageContentVC.pageIndex = index
        return pageContentVC
        
    }
    
    // MARK: - PageView Controller Data Source
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! PageContentViewController).pageIndex as Int
        
        if (index == NSNotFound || index == 0) {
            return nil
        }
        
        index--
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! PageContentViewController).pageIndex as Int
        
        if (index == NSNotFound || index == self.pageTitles.count - 1) {
            return nil
        }
        
        index++
        return self.viewControllerAtIndex(index)
        
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
