//
//  NotificationViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 10/3/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NotificationCellDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noNotificationLabel: UILabel!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var tableViewController = UITableViewController()
    var refreshControl: UIRefreshControl!
    var notifications:[Notification] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        self.refreshUI(reload: true)
        self.lightStatusBar()
        self.fetchNotifications()
    }
    
    func fetchNotifications(){
        APIManager.fetchNotifications(controller: self) { (notifications) in
            self.notifications = notifications
            self.refreshControl.endRefreshing()
            self.refreshUI()
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
        cell.loadNotification(notification)
        return cell
    }
    
    func open(event: Event){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        vc.event = event
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func open(post: Post){
        APIManager.fetchAssociation(association_id: post.association!, controller: self) { (opt_assos) in
            guard let assos = opt_assos else { return }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
            vc.post = post
            vc.association = assos
            self.navigationController?.pushViewController(vc, animated: true)
        }
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
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
            vc.post = post
            vc.association = assos
            vc.activeComment = comment
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func didRead(notification: Notification){
        APIManager.readNotification(notification: notification, controller: self) { (opt_notif) in
            
        }
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
    }
    
    func scrollToTop(){
        self.tableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    @IBAction func reloadAction(_ sender: AnyObject) {
        self.refreshUI(reload: true)
        self.fetchNotifications()
    }
    
    
}
