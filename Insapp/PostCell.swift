//
//  PostCell.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/15/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit
import FaveButton


protocol PostCellDelegate {
    func commentAction(post: Post, forCell cell: PostCell, showKeyboard: Bool)
    func likeAction(post: Post, forCell cell: PostCell, liked: Bool)
    func associationAction(association: Association)
}

class PostCell: UITableViewCell, FaveButtonDelegate {
    
    @IBOutlet weak var associationImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var likeButton: FaveButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var associationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var gradientView: UIView!
    
    let queue = DispatchQueue(label: "test", qos: .background, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.never, target: nil)
    
    var association:Association!
    var delegate: PostCellDelegate?
    var parent: UIViewController!
    var post:Post!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        DispatchQueue.main.async {
            self.likeButton.delegate = self
            self.associationImageView.layer.cornerRadius = self.associationImageView.frame.width/2
            self.associationImageView.layer.masksToBounds = true
            self.computeGradientView()
        }
    }
    
    func loadPost(_ post: Post, forAssociation association: Association){
        self.post = post
        self.likeButton.isSelected = post.likes!.contains(User.fetch()!.id!)
        self.association = association
        self.associationLabel.text = "@\(association.name!.lowercased())"
        DispatchQueue.main.async {
            self.associationImageView.downloadedFrom(link: kCDNHostname + association.profilePhotoURL!)
            self.postImageView.downloadedFrom(link: kCDNHostname + post.photourl!)
        }
        
        let height = post.imageSize!["height"]!
        let ratio = self.frame.size.width/post.imageSize!["width"]!
        self.postImageViewHeightConstraint.constant = ratio * height
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
        //DispatchQueue.main.async {
            //self.computeGradientView()
            //self.descriptionLabel.sizeToFit()
        //}
    }
    
    func renderStaticData(){
        self.titleLabel.text = post.title!
        self.commentLabel.text = "(\(post.comments!.count))"
        self.likeLabel.text = "(\(post.likes!.count))"
        self.descriptionLabel.text = post.desc! + "\n\n\n\n"
        self.timestampLabel.text = post.date!.timestamp()
        
        //let like_image = (post.likes!.contains(User.fetch()!.id!) ? #imageLiteral(resourceName: "liked") : #imageLiteral(resourceName: "like"))
        //self.likeButton.setImage(like_image, for: .normal)
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(PostCell.commentAction(_:)))
        self.postImageView.isUserInteractionEnabled = true
        self.postImageView.addGestureRecognizer(tapGesture1)
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(PostCell.commentAction(_:)))
        self.gradientView.addGestureRecognizer(tapGesture2)
        
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(PostCell.handleTapGesture))
        self.associationLabel.addGestureRecognizer(tapGesture3)
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
        self.bringSubview(toFront: self.gradientView)
    }
    
    func faveButton(_ faveButton: FaveButton, didSelected selected: Bool){
        delegate?.likeAction(post: self.post, forCell: self, liked: post.likes!.contains(User.fetch()!.id!))
    }
    
    func faveButtonDotColors(_ faveButton: FaveButton) -> [DotColors]?{
        if( faveButton === self.likeButton ){
            return [
                DotColors(first: color(0x7DC2F4), second: color(0xE2264D)),
                DotColors(first: color(0xF8CC61), second: color(0x9BDFBA)),
                DotColors(first: color(0xAF90F4), second: color(0x90D1F9)),
                DotColors(first: color(0xE9A966), second: color(0xF8C852)),
                DotColors(first: color(0xF68FA7), second: color(0xF6A2B8))
            ]
        }
        return nil
    }
    
    @IBAction func commentAction(_ sender: AnyObject) {
        let keyboard = (sender as? UIView == self.commentButton)
        delegate?.commentAction(post: self.post, forCell: self, showKeyboard: keyboard)
    }
    
    @IBAction func likeAction(_ sender: AnyObject) {
        self.likeButton.isSelected = !self.likeButton.isSelected
        delegate?.likeAction(post: self.post, forCell: self, liked: post.likes!.contains(User.fetch()!.id!))
    }
    
    @IBAction func associationAction(_ sender: AnyObject) {
        delegate?.associationAction(association: self.association)
    }
    
    func handleTapGesture(){
        delegate?.associationAction(association: self.association)
    }
}
