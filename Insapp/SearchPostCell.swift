//
//  SearchPostCell.swift
//  Insapp
//
//  Created by Guillaume Courtet on 08/11/2016.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import UIKit

class SearchPostCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate,  UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var postCollectionView: UICollectionView!
    
    var delegate: PostCellDelegate?
    var posts: [Post] = []
    var parent: UIViewController!
    var more = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.postCollectionView.delegate = self
        self.postCollectionView.dataSource = self
    }
    
    override func layoutSubviews() {
        let layout: UICollectionViewFlowLayout = self.postCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        
        self.postCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kSearchPostCell)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(more == 1){
            return posts.count
        }
        else {
        return min(6,(posts.count))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.postCollectionView.frame.width - 5)/3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kSearchPostCell, for: indexPath)
        let imageView = UIImageView(frame: cell.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        cell.addSubview(imageView)
        let post = self.posts[indexPath.row]
        imageView.downloadedFrom(link: kCDNHostname + post.photourl!)
        return cell
    }
    
    func loadPosts(_ posts: [Post]){
        self.posts = posts
        self.postCollectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = self.posts[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NewsViewController") as! NewsViewController
        vc.activePost = post
        vc.canReturn = true
        vc.canRefresh = false
        vc.canSearch = false
        self.parent?.navigationController?.pushViewController(vc, animated: true)
    }
}
