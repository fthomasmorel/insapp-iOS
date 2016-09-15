//
//  PostCell.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/15/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

let kPostCell = "kPostCell"
let kPostCellEmptyHeight = CGFloat(180)

protocol PostCellDelegate {
    func commentAction(post: Post, forCell cell: PostCell)
    func likeAction(post: Post, forCell cell: PostCell, liked: Bool)
    func associationAction(association: Association)
}

class PostCell: UITableViewCell {
    
    @IBOutlet weak var associationImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var associationLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var gradientView: UIView!
    
    
    static let fetchPhotoGroup = DispatchGroup()
    
    var association:Association!
    var delegate: PostCellDelegate?
    var post:Post!
    
    func loadPost(_ post: Post){
        self.post = post
        APIManager.fetchAssociation(association_id: post.association!, completion: { (opt_asso) in
            guard let association = opt_asso else { return }
            self.association = association
            self.associationLabel.text = "@\(association.name!.lowercased())"
            self.associationImageView.downloadedFrom(link: kCDNHostname + association.profilePhotoURL!)
            self.associationImageView.layer.cornerRadius = self.associationImageView.frame.width/2
            self.associationImageView.layer.masksToBounds = true
        })
        self.postImageView.downloadedFrom(link: kCDNHostname + post.photourl!)
        
        let ratio = self.frame.size.width/post.imageSize!["width"]!
        let height = post.imageSize!["height"]! * ratio
        
        self.postImageViewHeightConstraint.constant = height
        self.updateConstraintsIfNeeded()
        
        self.renderStaticData()
    }
    
    func reload(post: Post){
        self.post = post
        self.renderStaticData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.descriptionTextView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        self.computeGradientView()
    }
    
    func renderStaticData(){
        self.titleLabel.text = post.title!
        self.commentLabel.text = "(\(post.comments!.count))"
        self.likeLabel.text = "(\(post.likes!.count))"
        self.descriptionTextView.text = post.desc
        
        let like_image = (post.likes!.contains(User.fetch()!.id!) ? #imageLiteral(resourceName: "liked") : #imageLiteral(resourceName: "like"))
        self.likeButton.setImage(like_image, for: .normal)
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(PostCell.commentAction(_:)))
        self.gradientView.addGestureRecognizer(tapGesture1)

        self.timestampLabel.text = self.post.date!.timestamp()
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(PostCell.handleTapGesture))
        self.associationLabel.addGestureRecognizer(tapGesture2)
    }
    
    func computeGradientView(){
        let opaqueColor = UIColor.white
        let transColor = opaqueColor.withAlphaComponent(0)
        
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [opaqueColor.cgColor, transColor.cgColor]
        gradient.locations = [0 , 1]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 0.1)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.gradientView.frame.size.width, height: self.gradientView.frame.size.height)
        
        if let sublayers = self.gradientView.layer.sublayers {
            for sublayer in sublayers {
                sublayer.removeFromSuperlayer()
            }
        }

        self.gradientView.layer.insertSublayer(gradient, at: 0)
    }
    
    @IBAction func commentAction(_ sender: AnyObject) {
        delegate?.commentAction(post: self.post, forCell: self)
    }
    
    @IBAction func likeAction(_ sender: AnyObject) {
        delegate?.likeAction(post: self.post, forCell: self, liked: post.likes!.contains(User.fetch()!.id!))
    }
    
    @IBAction func associationAction(_ sender: AnyObject) {
        delegate?.associationAction(association: self.association)
    }
    
    func handleTapGesture(){
        delegate?.associationAction(association: self.association)
    }
}
