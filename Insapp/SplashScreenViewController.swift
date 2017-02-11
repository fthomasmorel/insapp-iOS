//
//  SplashScreenViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/13/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

class SpashScreenViewController: UIViewController {
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let credentials = Credentials.fetch() {
            self.login(credentials)
        }else{
            self.signin()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.lightStatusBar()
        self.loader.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.5) { 
            self.imageView.frame.origin.y -= self.imageView.frame.width/2
            self.loader.alpha = 1
        }
    }
    
    func login(_ credentials:Credentials){
        APIManager.login(credentials, controller: self, completion: { (opt_cred, opt_user) in
            guard let _ = opt_cred else { self.signin() ; return }
            guard let _ = opt_user else { self.signin() ; return }
            self.displayTabViewController()
        })
    }
    
    func signin(){
        DispatchQueue.main.async {
            self.loadViewController(name: "TutorialViewController")
        }
    }
    
    func displayTabViewController(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var completion: ((UIViewController) -> Void)? = nil
        if let notification = appDelegate.notification {
            completion = { viewController in
                guard let type = notification["type"] as? String, let content = notification["content"] as? String else { return }
                switch type {
                case kNotificationTypeEvent:
                    self.loadEventViewController(viewController as! UITabBarController, event_id: content)
                    break
                case kNotificationTypePost:
                    self.loadPostViewController(viewController as! UITabBarController, post_id: content)
                    break
                case kNotificationTypeTag:
                    guard let comment = notification["comment"] as? String else { return }
                    self.loadCommentViewController(viewController as! UITabBarController, post_id: content, comment_id: comment)
                    break
                default:
                    break
                }
                
            }
        }
        self.loadViewController(name: "TabViewController", completion: completion)
    }
    
    func loadEventViewController(_ controller: UITabBarController, event_id: String){
        let navigationController = (controller.selectedViewController as! UINavigationController)
        let viewController = navigationController.topViewController
        controller.selectedIndex = 3
        APIManager.fetchEvent(event_id: event_id, controller: viewController!, completion: { (opt_event) in
            guard let event = opt_event else { return }
            DispatchQueue.main.async {
                let controller = (controller.selectedViewController as! UINavigationController).topViewController
                (controller as! NotificationCellDelegate).open(event: event)
            }
        })
    }
    
    func loadPostViewController(_ controller: UITabBarController, post_id: String){
        let navigationController = (controller.selectedViewController as! UINavigationController)
        let viewController = navigationController.topViewController
        controller.selectedIndex = 3
        APIManager.fetchPost(post_id: post_id, controller: viewController!, completion: { (opt_post) in
            guard let post = opt_post else { return }
            DispatchQueue.main.async {
                let controller = (controller.selectedViewController as! UINavigationController).topViewController
                (controller as! NotificationCellDelegate).open(post: post)
            }
        })
    }
    
    func loadCommentViewController(_ controller: UITabBarController, post_id: String, comment_id: String){
        let navigationController = (controller.selectedViewController as! UINavigationController)
        let viewController = navigationController.topViewController
        controller.selectedIndex = 3
        APIManager.fetchPost(post_id: post_id, controller: viewController!, completion: { (opt_post) in
            guard let post = opt_post else { return }
            DispatchQueue.main.async {
                let controller = (controller.selectedViewController as! UINavigationController).topViewController
                (controller as! NotificationCellDelegate).open(post: post, withCommentId: comment_id)
            }
        })
    }
    
    func loadCommentViewController(_ controller: UITabBarController, event_id: String, comment_id: String){
        let navigationController = (controller.selectedViewController as! UINavigationController)
        let viewController = navigationController.topViewController
        controller.selectedIndex = 3
        APIManager.fetchEvent(event_id: event_id, controller: viewController!, completion: { (opt_event) in
            guard let event = opt_event else { return }
            DispatchQueue.main.async {
                let controller = (controller.selectedViewController as! UINavigationController).topViewController
                (controller as! NotificationCellDelegate).open(event: event, withCommentId: comment_id)
            }
        })
    }
    
    func loadViewController(name: String, completion: ((_ vc: UIViewController) -> Void)? = nil){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: name)
        if name == "TabViewController" {
            (vc as! UITabBarController).delegate = UIApplication.shared.delegate as! UITabBarControllerDelegate?
            DispatchQueue.global().async {
                APIManager.fetchNotifications(controller: self, completion: { (notifs) in
                    let badge = notifs.filter({ (notif) -> Bool in return !notif.seen }).count
                    DispatchQueue.main.async {
                        guard badge > 0 else { return }
                        (vc as! UITabBarController).tabBar.items?[3].badgeValue = "\(badge)"
                    }
                })
            }
        }
        self.present(vc, animated: true) {
            guard let _ = completion else { return }
            completion!(vc)
        }
    }
}
