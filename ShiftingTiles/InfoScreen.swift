//
//  InfoScreen.swift
//  ShiftingTiles
//
//  Created by Parker Lewis on 1/13/15.
//  Copyright (c) 2015 Parker Lewis. All rights reserved.
//

import UIKit

class InfoScreen: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    let colorPalette = ColorPalette()

    var pageViewController : UIPageViewController!
    var firstVC : UIViewController!
    var viewControllers = [UIViewController]()
    
    var currentVCIndex = 0
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Apply color scheme
        self.view.backgroundColor = self.colorPalette.fetchLightColor()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureDismiss = UITapGestureRecognizer(target: self, action: "dismissInfoScreen:")
        self.view.addGestureRecognizer(tapGestureDismiss)

        
        // Setup pageViewController
        self.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        
        
        // Set the initial ViewController
        self.firstVC = RulesScreen1(nibName: "RulesScreen1", bundle: NSBundle.mainBundle())
        let viewControllers: NSArray = [self.firstVC]
        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: nil)
        self.viewControllers.append(self.firstVC)
        
        // Set up the rest of the VCs
        self.setupVCArray()
        
        // Add PageViewController to the InfoScreen VC
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)

        
        // Appearance of the page control dots
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = self.colorPalette.fetchDarkColor()
        appearance.currentPageIndicatorTintColor = UIColor.whiteColor()
        appearance.backgroundColor = UIColor.clearColor()

    }
    
    
    func setupVCArray() {
        let page2 = RulesScreen2(nibName: "RulesScreen2", bundle: NSBundle.mainBundle())
//        let page3 = RulesScreen2(nibName: "RulesScreen2", bundle: NSBundle.mainBundle())
//        let page4 = RulesScreen2(nibName: "RulesScreen2", bundle: NSBundle.mainBundle())
        let page5 = Acknowledgements(nibName: "Acknowledgements", bundle: NSBundle.mainBundle())
    
        self.viewControllers.append(page2)
//        self.viewControllers.append(page3)
//        self.viewControllers.append(page4)
        self.viewControllers.append(page5)
    }
    
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
//        if viewController.isKindOfClass(RulesScreen1) {
//            return nil
//        }
        if viewController.isKindOfClass(RulesScreen2) {
            return self.viewControllers[0]
        }
        if viewController.isKindOfClass(Acknowledgements) {
            return self.viewControllers[1]
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        

        if viewController.isKindOfClass(RulesScreen1) {
            return self.viewControllers[1]
        }
        if viewController.isKindOfClass(RulesScreen2) {
            return self.viewControllers[2]
        }
//        if viewController.isKindOfClass(Acknowledgements) {
//            return nil
//        }
        return nil
    }
    
    
    
    
    // MARK: - Page Indicator
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 3
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }

    
    
    
    
    
    
    
    //        self.infoText.text = "The objective of the game is to form the original image by shifting the tiles around until they are in the proper order. Tap one tile and then another to swap their positions. The black arrows on the top and left of the tiles allow entire rows and columns to swap postions.\n\nThe HINT button shows the first incorrect tile and the correct tile which it should be swapped with.\n\nThe SOLVE button will auto-solve the puzzle by swapping tiles until complete.\n\nUse the Show Original button to remind yourself what the original image looks like.\n\nImages were culled from unsplash.com and from Dale Arveson: phalconphotography.smugmug.com\n\nFeedback, questions, comments are welcome: pakalewis@gmail.com\n\nThe source code can be viewed here: github.com/pakalewis/shiftingtiles\n\ntest\n\ntest\n\ntest\n\ntest\n\ntest\n\ntest\n\ntest\n\ntest\n\ntest"
    //
    
    
    func dismissInfoScreen(sender: UIGestureRecognizer) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
