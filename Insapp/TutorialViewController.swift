//
//  TutorialViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/20/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class TutorialViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pageViewControllers:[TutorialPageViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        for i in 0...kTutorialPages.count-1 {
            let pageName = kTutorialPages[i]
            let controller = storyboard.instantiateViewController(withIdentifier: pageName) as! TutorialPageViewController
            controller.pageName = pageName
            controller.index = i
            controller.completion = { pageName in self.pageAction(page: pageName) }
            self.pageViewControllers.append(controller)
        }
        
        self.dataSource = self
        self.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setViewControllers([self.pageViewControllers.first!], direction: .forward, animated: false, completion: nil)
        self.view.backgroundColor = kRedColor
    }
    
    func viewControllerAtIndex(index: Int) -> UIViewController? {
        if index >= self.pageViewControllers.count  { return nil }
        if index < 0                                { return nil }
        return self.pageViewControllers[index]
    }
 
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = (viewController as! TutorialPageViewController).index! - 1
        return self.viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = (viewController as! TutorialPageViewController).index! + 1
        return self.viewControllerAtIndex(index: index)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return kTutorialPages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func pageAction(page: String){
        if page == "TutorialNotificationViewController" {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            delegate.registerForNotification {
                let alert = UIAlertController(title: "", message: "Les notifications ont été activées", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(defaultAction)
                self.present(alert, animated: true, completion: nil)
            }
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SigninViewController")
            self.present(vc, animated: true, completion: nil)
        }
    }
}
