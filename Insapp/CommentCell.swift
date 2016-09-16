//
//  CommentCell.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/15/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit


let kCommentCell = "kCommentCell"
let kCommentCellEmptyHeight = 41
let kCommentCellEmptyWidth = 64

class CommentCell: UITableViewCell {
    
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var frontView: UIView!
    
    var deleteCompletion:((Comment) -> ())?
    var comment: Comment!
    var user: User!
    
    func addGestureRecognizer() {
        let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(CommentCell.handleSwipeGesture(_:)))
        swipeGestureRight.direction = .right
        self.frontView.addGestureRecognizer(swipeGestureRight)
        
        let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(CommentCell.handleSwipeGesture(_:)))
        swipeGestureLeft.direction = .left
        self.frontView.addGestureRecognizer(swipeGestureLeft)
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
//        if self.user == nil {
//            self.isUserInteractionEnabled = false
//        }
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

    
    func loadUserComment(_ comment: Comment){
        self.contentTextView.text = comment.content!
        let height = self.contentTextView.contentSize.height
        var newFrame = self.contentTextView.frame
        newFrame.size.height = height
        self.contentTextView.frame = newFrame
        self.timestampLabel.text = comment.date!.timestamp()
        self.comment = comment
        
        DispatchQueue.global().async {
            APIManager.fetch(user_id: comment.user_id!) { (opt_user) in
                guard let user = opt_user else { return }
                //let promotion = user.promotion
                self.usernameLabel.text = "@\(user.username!.lowercased())"
                self.roundUserImage()
                self.user = user
                if user.id! == User.fetch()!.id! {
                    self.addGestureRecognizer()
                }else{
                    self.removeGestureRecognizer()
                }
            }
        }

    }
    
    func loadAssociationComment(association: Association, forPost post: Post){
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
        }
    }
    
    @IBAction func deleteAction(_ sender: AnyObject) {
        self.deleteCompletion?(self.comment)
    }
    
    static func heightForContent(_ content: String, forWidth width: CGFloat) -> CGFloat {
        let res = UITextView.heightForContent(content, andWidth: width-CGFloat(kCommentCellEmptyWidth)) + CGFloat(kCommentCellEmptyHeight)
        return res
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
}
