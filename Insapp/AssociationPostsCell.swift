//
//  AssociationPostsCell.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 2/7/17.
//  Copyright © 2017 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

let kAssociationPostsCell = "kAssociationPostsCell"
let kImagePostCell = "kImagePostCell"

class ImagePostCell: UICollectionViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    
    override func layoutSubviews() {
        self.postImageView.layer.cornerRadius = 10
        self.postImageView.layer.masksToBounds = true
    }
    
}

protocol AssociationPostsDelegate {
    func showAllPostAction()
    func show(post: Post)
}

class AssociationPostsCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var seeAllbutton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var posts: [Post] = []
    var association: Association!
    var delegate: AssociationPostsDelegate?
    
    override func layoutSubviews() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.showsHorizontalScrollIndicator = false
        let layout: UICollectionViewFlowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        self.collectionView.register(UINib(nibName: "ImagePostCell", bundle: nil), forCellWithReuseIdentifier: kImagePostCell)
    }

    func load(posts: [Post], forAssociation association: Association) {
        self.posts = posts
        self.association = association
        self.backgroundColor = UIColor.hexToRGB(self.association.bgColor!)
        self.seeAllbutton.setTitleColor(UIColor.hexToRGB(self.association.fgColor!), for: .normal)
        self.titleLabel.textColor = UIColor.hexToRGB(self.association.fgColor!)
        self.collectionView.backgroundColor = UIColor.hexToRGB(self.association.bgColor!)
        self.collectionView.reloadData()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(self.posts.count, 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 170, height: 170)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: kImagePostCell, for: indexPath as IndexPath) as! ImagePostCell
        let post = self.posts[indexPath.row]
        cell.postImageView.downloadedFrom(link: kCDNHostname + post.photourl! )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = self.posts[indexPath.row]
        self.delegate?.show(post: post)
    }

    
    @IBAction func seeAllAction(_ sender: Any) {
        self.delegate?.showAllPostAction()
    }
}
