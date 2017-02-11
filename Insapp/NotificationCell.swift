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
    func open(post: Post, withCommentId comment_id: String)
    func open(event: Event, withComment comment: Comment)
    func open(event: Event, withCommentId comment_id: String)
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
        self.addGestureRecognizer(tap2)
    }
    
    func load(_ notification: Notification, withEvent event: Event, withSender sender: Association){
        self.load(notification: notification)
        self.event = event
        self.associationSender = sender
        self.senderImageView.downloadedFrom(link: kCDNHostname + sender.profilePhotoURL!)
        self.contentImageView.downloadedFrom(link: kCDNHostname + event.photoURL!)
    }
    
    func load(_ notification: Notification, withPost post: Post, withSender sender: Association){
        self.load(notification: notification)
        self.post = post
        self.associationSender = sender
        self.senderImageView.downloadedFrom(link: kCDNHostname + sender.profilePhotoURL!)
        self.contentImageView.downloadedFrom(link: kCDNHostname + post.photourl!)
    }
    
    func load(_ notification: Notification, withPost post: Post, withUser user: User){
        self.load(notification: notification)
        self.post = post
        self.userSender = user
        self.senderImageView.image = user.avatar()
        self.contentImageView.downloadedFrom(link: kCDNHostname + post.photourl!)
    }
    
    func load(_ notification: Notification, withEvent event: Event, withUser user: User){
        self.load(notification: notification)
        self.event = event
        self.userSender = user
        self.senderImageView.image = user.avatar()
        self.contentImageView.downloadedFrom(link: kCDNHostname + event.photoURL!)
    }
    
    func load(notification: Notification){
        
        let attributedString = NSMutableAttributedString(string: notification.message! + " ")
        let dateString = NSMutableAttributedString(string: notification.date!.timestamp(), attributes:
            [NSForegroundColorAttributeName: kDarkGreyColor])
        attributedString.append(dateString)
        self.notification = notification
        self.messageLabel.attributedText = attributedString
        self.comment = notification.comment
        
        self.backgroundColor = .white
        if !notification.seen { self.backgroundColor = kLightGreyColor }
        
        self.senderImageView.layer.cornerRadius = 20
        self.senderImageView.layer.masksToBounds = true
        self.senderImageView.backgroundColor = kWhiteColor
        self.senderImageView.layer.borderColor = kDarkGreyColor.cgColor
        self.senderImageView.layer.borderWidth = 1

    }
    
    
    func didTouchView(){
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
        case kNotificationTypeEventTag:
            if let event = self.event, let comment = self.comment {
                self.delegate?.open(event: event, withComment: comment)
                return
            }
        default:
            break
        }
    }
    
    func didTouchSender(){
        if (self.notification.type! == kNotificationTypeTag || self.notification.type! == kNotificationTypeEventTag), let user = self.userSender{
            self.delegate?.open(user: user)
        }
        if self.notification.type! != kNotificationTypeTag, let association = self.associationSender{
            self.delegate?.open(association: association)
        }
    }
}
