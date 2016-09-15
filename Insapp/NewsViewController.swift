//
//  NewsViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/14/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PostCellDelegate {
    
    @IBOutlet weak var postTableView: UITableView!
    
    private let tableViewController = UITableViewController()
    var refreshControl: UIRefreshControl!
    var posts:[Post]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.postTableView.delegate = self
        self.postTableView.dataSource = self
        self.postTableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: kPostCell)
        
        self.addChildViewController(self.tableViewController)
        self.tableViewController.tableView = self.postTableView
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = UIColor.white.withAlphaComponent(0)
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(NewsViewController.fetchPosts), for: UIControlEvents.valueChanged)
        self.tableViewController.refreshControl = self.refreshControl
        self.postTableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.refreshControl.beginRefreshing()
        self.fetchPosts()
    }
    
    func fetchPosts(){
        APIManager.fetchLastestPosts { (posts) in
            self.refreshControl.endRefreshing()
            self.posts = posts
            self.postTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = self.posts[indexPath.row]
        let ratio = self.view.frame.size.width/post.imageSize!["width"]!
        return post.imageSize!["height"]! * ratio + kPostCellEmptyHeight
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = self.posts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: kPostCell, for: indexPath) as! PostCell
        cell.loadPost(post)
        cell.delegate = self
        return cell
    }
    
    func commentAction(post: Post, forCell cell: PostCell) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
        vc.association = cell.association
        vc.post = post
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func likeAction(post: Post, forCell cell: PostCell, liked: Bool) {
        let completion = { (opt_post:Optional<Post>) -> () in
            guard let new_post = opt_post else { return }
            guard let index = self.posts.index(of: post) else { return }
            self.posts[index] = new_post
            cell.reload(post: new_post)
        }
        if liked {
            APIManager.dislikePost(post_id: post.id!, completion: completion)
        }else{
            APIManager.likePost(post_id: post.id!, completion: completion)
        }
    }
    
    func associationAction(association: Association) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AssociationViewController") as! AssociationViewController
        vc.association = association
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
