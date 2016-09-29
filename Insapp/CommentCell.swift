//
//  CommentCell.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/15/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit




protocol CommentCellDelegate {
    func delete(comment: Comment)
    func open(user: User)
    func open(association: Association)
}

class CommentCell: UITableViewCell {
    
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var frontView: UIView!
    
    var delegate: CommentCellDelegate?
    var parent: UIViewController!
    var association: Association?
    var comment: Comment?
    var user: User?
    
    func addGestureRecognizer() {
        let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(CommentCell.handleSwipeGesture(_:)))
        swipeGestureRight.direction = .right
        self.frontView.addGestureRecognizer(swipeGestureRight)
        
        let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(CommentCell.handleSwipeGesture(_:)))
        swipeGestureLeft.direction = .left
        self.frontView.addGestureRecognizer(swipeGestureLeft)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CommentCell.handleTapGesture(_:)))
        self.usernameLabel.addGestureRecognizer(tapGesture)
    }
    
    func removeGestureRecognizer() {
        if let gestureRecognizers = self.frontView.gestureRecognizers {
            for gestureRecognizer in gestureRecognizers {
                self.frontView.removeGestureRecognizer(gestureRecognizer)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CommentCell.handleTapGesture(_:)))
        self.usernameLabel.addGestureRecognizer(tapGesture)
    }
    
    func preloadUserComment(_ comment: Comment){
        self.usernameLabel.text = "@\(comment.user_id!.lowercased())"
        self.timestampLabel.text = comment.date!.timestamp()
        
        self.contentTextView.text = comment.content!
        let contentSize = self.contentTextView.sizeThatFits(self.contentTextView.bounds.size)
        var frame = self.contentTextView.frame
        frame.size.height = contentSize.height
        self.contentTextView.frame = frame
    }
    
    func preloadAssociationComment(association: Association, forPost post: Post){
        self.usernameLabel.text = "@\(association.name!.lowercased())"
        self.timestampLabel.text = post.date!.timestamp()
        
        self.contentTextView.text = post.desc!
        let contentSize = self.contentTextView.sizeThatFits(self.contentTextView.bounds.size)
        var frame = self.contentTextView.frame
        frame.size.height = contentSize.height
        self.contentTextView.frame = frame
    }

    
    func loadUserComment(_ comment: Comment, user: User){
        self.contentTextView.text = comment.content!
        let height = self.contentTextView.contentSize.height
        var newFrame = self.contentTextView.frame
        newFrame.size.height = height
        self.contentTextView.frame = newFrame
        self.timestampLabel.text = comment.date!.timestamp()
        self.comment = comment
        
        self.userImageView.image = user.avatar()
        self.usernameLabel.text = "@\(user.username!.lowercased())"
        self.roundUserImage()
        self.user = user
        if user.id! == User.fetch()!.id! {
            self.addGestureRecognizer()
        }else{
            self.removeGestureRecognizer()
        }
    }
    
    func loadAssociationComment(association: Association, forPost post: Post){
        self.association = association
        self.contentTextView.text = post.desc!
        
        let height = self.contentTextView.contentSize.height
        var newFrame = self.contentTextView.frame
        newFrame.size.height = height
        self.contentTextView.frame = newFrame
        
        self.usernameLabel.text = "@\(association.name!.lowercased())"
        self.contentTextView.sizeToFit()
        self.timestampLabel.text = post.date!.timestamp()
        self.userImageView.downloadedFrom(link: kCDNHostname + association.profilePhotoURL!)
        self.roundUserImage()
        
        self.removeGestureRecognizer()
    }
    
    func roundUserImage(){
        DispatchQueue.main.async {
            self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width/2
            self.userImageView.layer.masksToBounds = true
            self.userImageView.backgroundColor = kWhiteColor
            self.userImageView.layer.borderColor = kDarkGreyColor.cgColor
            self.userImageView.layer.borderWidth = 1
        }
    }
    
    func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case UISwipeGestureRecognizerDirection.right:
            self.closeSubmenu()
            break
        case UISwipeGestureRecognizerDirection.left:
            self.openSubmenu()
            break
        default: break
        }
    }
 
    func openSubmenu(){
        if self.frontView.frame.origin.x == 0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.frontView.frame.origin.x-=80
            })
        }
    }
    
    func closeSubmenu(){
        if self.frontView.frame.origin.x != 0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.frontView.frame.origin.x = 0
            })
        }
    }
    
    @IBAction func handleTapGesture(_ sender: AnyObject) {
        if let user = self.user {
            self.delegate?.open(user: user)
        }
        if let association = self.association {
            self.delegate?.open(association: association)
        }
    }
    
    @IBAction func deleteAction(_ sender: AnyObject) {
        self.delegate?.delete(comment: self.comment!)
    }
    
}
