//
//  NotificationCell.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 10/3/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

protocol NotificationCellDelegate {
    func open(post: Post)
    func open(user: User)
    func open(event: Event)
    func open(association: Association)
    func open(post: Post, withComment comment: Comment)
    func didRead(notification: Notification)
}

class NotificationCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var senderImageView: UIImageView!
    
    var delegate: NotificationCellDelegate?
    
    var event: Event?
    var post: Post?
    var comment: Comment?
    var userSender: User?
    var associationSender: Association?
    var notification: Notification!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(NotificationCell.didTouchSender))
        self.senderImageView.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(NotificationCell.didTouchView))
        self.contentImageView.addGestureRecognizer(tap2)
    }
    
    func loadNotification(_ notification: Notification){
        self.notification = notification
        self.messageLabel.text = notification.message!
        self.comment = notification.comment
        
        self.backgroundColor = .white
        if !notification.seen { self.backgroundColor = kLightGreyColor }
        
        self.senderImageView.layer.cornerRadius = 20
        self.senderImageView.layer.masksToBounds = true
        self.senderImageView.backgroundColor = kWhiteColor
        self.senderImageView.layer.borderColor = kDarkGreyColor.cgColor
        self.senderImageView.layer.borderWidth = 1
        
        switch notification.type! {
        case kNotificationTypeEvent:
            self.generateEventNotificationCell(notification)
            break
        case kNotificationTypePost:
            self.generatePostNotificationCell(notification)
            break
        case kNotificationTypeTag:
            self.generateTagNotificationCell(notification)
            break
        default: break
        }
    }
    
    func generateEventNotificationCell(_ notification: Notification){
        APIManager.fetchEvent(event_id: notification.content!, controller: self.delegate! as! UIViewController) { (opt_event) in
            if let event = opt_event {
                self.updateCellWithEvent(event)
            }
        }
        APIManager.fetchAssociation(association_id: notification.sender!, controller: self.delegate! as! UIViewController, completion: { (opt_assos) in
            if let assos = opt_assos {
                self.updateCellWithAssociation(assos)
            }
        })
    }
    
    func generatePostNotificationCell(_ notification: Notification){
        APIManager.fetchPost(post_id: notification.content!, controller: self.delegate! as! UIViewController) { (opt_post) in
            if let post = opt_post {
                self.updateCellWithPost(post)
            }
        }
        APIManager.fetchAssociation(association_id: notification.sender!, controller: self.delegate! as! UIViewController, completion: { (opt_assos) in
            if let assos = opt_assos {
                self.updateCellWithAssociation(assos)
            }
        })
    }
    
    func generateTagNotificationCell(_ notification: Notification){
        APIManager.fetchPost(post_id: notification.content!, controller: self.delegate! as! UIViewController) { (opt_post) in
            if let post = opt_post {
                self.updateCellWithPost(post)
            }
        }
        APIManager.fetch(user_id: notification.sender!, controller: self.delegate! as! UIViewController, completion: { (opt_user) in
            if let user = opt_user {
                self.updateCellWithUser(user)
            }
        })
    }
    
    func updateCellWithEvent(_ event: Event){
        DispatchQueue.main.async {
            self.event = event
            self.contentImageView.downloadedFrom(link: kCDNHostname + event.photoURL!)
        }
    }
    
    func updateCellWithPost(_ post: Post){
        DispatchQueue.main.async {
            self.post = post
            self.contentImageView.downloadedFrom(link: kCDNHostname + post.photourl!)
        }
    }
    
    func updateCellWithAssociation(_ association: Association){
        DispatchQueue.main.async {
            self.associationSender = association
            self.senderImageView.downloadedFrom(link: kCDNHostname + association.profilePhotoURL!)
        }
    }
    
    func updateCellWithUser(_ user: User){
        DispatchQueue.main.async {
            self.userSender = user
            self.senderImageView.image = user.avatar()
        }
    }
    
    func didTouchView(){
        self.delegate?.didRead(notification: self.notification)
        switch self.notification.type! {
        case kNotificationTypeEvent:
            if let event = self.event {
                self.delegate?.open(event: event)
                return
            }
        case kNotificationTypePost:
            if let post = self.post {
                self.delegate?.open(post: post)
                return
            }
        case kNotificationTypeTag:
            if let post = self.post, let comment = self.comment {
                self.delegate?.open(post: post, withComment: comment)
                return
            }
        default:
            break
        }
    }
    
    func didTouchSender(){
        if self.notification.type! == kNotificationTypeTag, let user = self.userSender{
            self.delegate?.open(user: user)
        }
        if self.notification.type! != kNotificationTypeTag, let association = self.associationSender{
            self.delegate?.open(association: association)
        }
        self.delegate?.didRead(notification: self.notification)
    }
}
