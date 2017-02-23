//
//  NotificationViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 10/3/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NotificationCellDelegate, CommentControllerDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noNotificationLabel: UILabel!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var tableViewController = UITableViewController()
    var refreshControl: UIRefreshControl!
    var notifications:[Notification]!
    
    var events:[String: Event]!
    var associations:[String: Association]!
    var users:[String: User]!
    var posts:[String: Post]!
    
    let group = DispatchGroup()
    let queue = DispatchQueue.global(qos: .background)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.posts = [:]
        self.users = [:]
        self.events = [:]
        self.associations = [:]
        self.notifications = []
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: kNotificationCell)
        
        self.addChildViewController(self.tableViewController)
        self.tableViewController.tableView = self.tableView
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = UIColor.white.withAlphaComponent(0)
        self.refreshControl.addTarget(self, action: #selector(NotificationViewController.fetchNotifications), for: UIControlEvents.valueChanged)
        self.tableViewController.refreshControl = self.refreshControl
        self.tableView.tableFooterView = UIView()
        self.tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.notifyGoogleAnalytics()
        self.lightStatusBar()
        self.hideNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.refreshUI(reload: true)
        DispatchQueue.global().async {
            self.fetchNotifications()
        }
    }
    
    func fetchNotifications(){
        APIManager.fetchNotifications(controller: self) { (notifications) in
            DispatchQueue.global().async {
                self.notifications = notifications
                for notification in notifications {
                    switch notification.type! {
                    case kNotificationTypeEvent:
                        self.download(eventId: notification.content!)
                        self.download(associationId: notification.sender!)
                        break
                    case kNotificationTypePost:
                        self.download(postId: notification.content!)
                        self.download(associationId: notification.sender!)
                        break
                    case kNotificationTypeTag:
                        self.download(postId: notification.content!)
                        self.download(userId: notification.sender!)
                        break
                    case kNotificationTypeEventTag:
                        self.download(eventId: notification.content!)
                        self.download(userId: notification.sender!)
                        break
                    default:
                        break
                    }
                }
                
                self.group.notify(queue: DispatchQueue.main, work: DispatchWorkItem(block: {
                    self.refreshControl.endRefreshing()
                    self.refreshUI()
                }))
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notification = self.notifications[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: kNotificationCell, for: indexPath) as! NotificationCell
        cell.delegate = self
        switch notification.type! {
        case kNotificationTypeEvent:
            let content = self.events[notification.content!]!
            let sender = self.associations[notification.sender!]!
            cell.load(notification, withEvent: content, withSender: sender)
            break
        case kNotificationTypePost:
            let content = self.posts[notification.content!]!
            let sender = self.associations[notification.sender!]!
            cell.load(notification, withPost: content, withSender: sender)
            break
        case kNotificationTypeTag:
            let content = self.posts[notification.content!]!
            let sender = self.users[notification.sender!]!
            cell.load(notification, withPost: content, withUser: sender)
            break
        case kNotificationTypeEventTag:
            let content = self.events[notification.content!]!
            let sender = self.users[notification.sender!]!
            cell.load(notification, withEvent: content, withUser: sender)
            break
        default:
            break
        }
        return cell
    }
    
    
    func open(event: Event){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        vc.event = event
        vc.association = self.associations[event.association!]!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func open(post: Post){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NewsViewController") as! NewsViewController
        vc.activePost = post
        vc.canReturn = true
        vc.canSearch = false
        vc.canRefresh = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func open(user: User){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
        vc.user_id = user.id
        vc.user = user
        vc.canReturn = true
        vc.isEditable = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func open(association: Association){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AssociationViewController") as! AssociationViewController
        vc.association = association
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func open(post: Post, withComment comment: Comment){
        APIManager.fetchAssociation(association_id: post.association!, controller: self) { (opt_assos) in
            guard let assos = opt_assos else { return }
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
                vc.comments = post.comments
                vc.activeComment = comment
                vc.association = assos
                vc.desc = post.desc
                vc.date = post.date
                vc.content = post
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func open(post: Post, withCommentId comment_id: String){
        guard let comment = post.comments?.filter({ (comment) -> Bool in
            return comment.id! == comment_id
        }).first else { return }
        self.open(post: post, withComment: comment)
    }
    
    func open(event: Event, withComment comment: Comment){
        APIManager.fetchAssociation(association_id: event.association!, controller: self) { (opt_assos) in
            guard let assos = opt_assos else { return }
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
                vc.event = event
                vc.association = assos
                vc.activeComment = comment
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func open(event: Event, withCommentId comment_id: String){
        guard let comment = event.comments?.filter({ (comment) -> Bool in
            return comment.id! == comment_id
        }).first else { return }
        self.open(event: event, withComment: comment)
    }
    
    func comment(content: AnyObject, comment: Comment, completion: @escaping (AnyObject, String, NSDate, [Comment]) -> ()){
        APIManager.comment(post_id: (content as! Post).id!, comment: comment, controller: self) { (opt_post) in
            guard let post = opt_post else { return }
            completion(post, post.desc!, post.date!, post.comments!)
        }
    }
    
    func uncomment(content: AnyObject, comment: Comment, completion: @escaping (AnyObject, String, NSDate, [Comment]) -> ()){
        APIManager.uncomment(post_id: (content as! Post).id!, comment_id: comment.id!, controller: self, completion: { (opt_post) in
            guard let post = opt_post else { return }
            completion(post, post.desc!, post.date!, post.comments!)
        })
    }
    
    func report(content: AnyObject, comment: Comment){
        APIManager.report(comment: comment, post: (content as! Post), controller: self)
    }

    
    func download(eventId: String){
        //guard self.events[eventId] == nil else { return }
        self.group.enter()
        self.queue.async(group: self.group, execute: {
            APIManager.fetchEvent(event_id: eventId, controller: self) { (opt_event) in
                guard let event = opt_event else { return }
                self.events[eventId] = event
                self.group.leave()
            }
        })
    }

    func download(postId: String){
        //guard self.posts[postId] == nil else { return }
        self.group.enter()
        self.queue.async(group: self.group, execute: {
            APIManager.fetchPost(post_id: postId, controller: self) { (opt_post) in
                guard let post = opt_post else { return }
                self.posts[postId] = post
                self.group.leave()
            }
        })
    }
    
    func download(associationId: String){
        guard self.associations[associationId] == nil else { return }
        self.group.enter()
        self.queue.async(group: self.group, execute: {
            APIManager.fetchAssociation(association_id: associationId, controller: self) { (opt_association) in
                guard let association = opt_association else { return }
                self.associations[associationId] = association
                self.group.leave()
            }
        })
    }
    
    func download(userId: String){
        guard self.users[userId] == nil else { return }
        self.group.enter()
        self.queue.async(group: self.group, execute: {
            APIManager.fetch(user_id: userId, controller: self) { (opt_user) in
                guard let user = opt_user else { return }
                self.users[userId] = user
                self.group.leave()
            }
        })
    }
    
    func refreshUI(reload:Bool = false){
        if self.notifications.count == 0 {
            if reload {
                self.tableView.isHidden = true
                self.noNotificationLabel.isHidden = true
                self.reloadButton.isHidden = true
                self.loader.isHidden = false
            }else{
                self.tableView.isHidden = true
                self.noNotificationLabel.isHidden = false
                self.reloadButton.isHidden = false
                self.loader.isHidden = true
            }
        }else{
            self.tableView.isHidden = false
            self.noNotificationLabel.isHidden = true
            self.reloadButton.isHidden = true
            self.loader.isHidden = false
            self.tableView.reloadData()
        }
        
        let application = UIApplication.shared
        application.applicationIconBadgeNumber = 0
        (self.navigationController?.parent as? UITabBarController)?.tabBar.items?[3].badgeValue = nil
        
        for notification in self.notifications {
            APIManager.readNotification(notification: notification, controller: self, completion: { (_) in })
        }
    }
    
    func scrollToTop(){
        self.tableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    
    @IBAction func reloadAction(_ sender: AnyObject) {
        self.refreshUI(reload: true)
        self.fetchNotifications()
    }
    
    
}
