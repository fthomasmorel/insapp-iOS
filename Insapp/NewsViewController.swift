//
//  NewsViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/14/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PostCellDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var postTableView: UITableView!  
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var noPostLabel: UILabel!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var searchView: UIView!
    
    private let tableViewController = UITableViewController()
    
    var searchViewController: UniversalSearchViewController!
    
    var refreshControl: UIRefreshControl?
    var activePost: Post?
    var activeAssociation: Association?
    var posts:[Post]! = []
    var associations:[String:Association] = [:]
    var canReturn = false
    var canRefresh = true
    var canSearch = true
    var backgroundSearchView : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.registerForRemoteNotifications()
        
        self.searchViewController = self.childViewControllers.last as? UniversalSearchViewController
        
        self.postTableView.delegate = self
        self.postTableView.dataSource = self
        self.postTableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: kPostCell)
        
        if canRefresh{
            self.addChildViewController(self.tableViewController)
            self.tableViewController.tableView = self.postTableView
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.backgroundColor = UIColor.white.withAlphaComponent(0)
            self.refreshControl?.addTarget(self, action: #selector(NewsViewController.fetchPosts), for: UIControlEvents.valueChanged)
            self.tableViewController.refreshControl = self.refreshControl
            self.postTableView.addSubview(refreshControl!)
        }
        
        self.searchBar.backgroundImage = UIImage()
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        (textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel)?.textColor = kDarkGreyColor
        textFieldInsideSearchBar!.textColor = kWhiteColor
        if let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView {
            glassIconView.image = glassIconView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            glassIconView.tintColor = kDarkGreyColor
        }
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = UIColor.white
        self.searchBar.delegate = self
        self.searchBar.showsCancelButton = false
        
        self.backgroundSearchView = UIView()
        self.backgroundSearchView.backgroundColor = .black
        self.backgroundSearchView.alpha = 0.7
        self.backgroundSearchView.isHidden = true
        self.view.addSubview(self.backgroundSearchView)
        self.searchView.isHidden = true
        self.view.bringSubview(toFront: self.searchView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.notifyGoogleAnalytics()
        self.lightStatusBar()
        self.backButton.isHidden = !self.canReturn
        self.hideNavBar()
        self.searchBar.isHidden = !self.canSearch
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.refreshUI(reload: true)
        DispatchQueue.global().async {
            if let post = self.activePost{
                self.posts = [post]
                self.fetchAssocations()
            }else{
                self.fetchPosts()
            }
        }
        self.backgroundSearchView.frame = self.postTableView.frame
        //self.view.bringSubview(toFront: self.backgroundSearchView)
    }
    
    func fetchPosts(){
        APIManager.fetchLastestPosts(controller: self, completion: { (posts) in
            self.posts = posts
            self.fetchAssocations()
        })
    }
    
    func fetchAssocations(){
        let group = DispatchGroup()
        for post in self.posts{
            if self.associations[post.association!] == nil {
                group.enter()
                APIManager.fetchAssociation(association_id: post.association!, controller: self, completion: { (opt_asso) in
                    guard let association = opt_asso else { return }
                    self.associations[association.id!] = association
                    group.leave()
                })
            }
        }
        
        group.notify(queue: DispatchQueue.main, work: DispatchWorkItem(block: {
            self.refreshControl?.endRefreshing()
            self.refreshUI()
        }))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = self.posts[indexPath.row]
        let ratio = self.view.frame.size.width/post.imageSize!["width"]!
        return post.imageSize!["height"]! * ratio + kPostCellEmptyHeight
        //return self.view.frame.size.width + kPostCellEmptyHeight
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.posts.count == 0 || self.associations.count == 0 ? 0 : self.posts.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = self.posts[indexPath.row]
        let association = self.associations[post.association!]!
        let cell = tableView.dequeueReusableCell(withIdentifier: kPostCell, for: indexPath) as! PostCell
        cell.parent = self
        cell.delegate = self
        cell.loadPost(post, forAssociation: association)
        return cell
    }
    
    func refreshUI(reload:Bool = false){
        if self.posts.count == 0 {
            if reload {
                self.postTableView.isHidden = true
                self.noPostLabel.isHidden = true
                self.reloadButton.isHidden = true
                self.loader.isHidden = false
            }else{
                self.postTableView.isHidden = true
                self.noPostLabel.isHidden = false
                self.reloadButton.isHidden = false
                self.loader.isHidden = true
            }
        }else{
            self.postTableView.isHidden = false
            self.noPostLabel.isHidden = true
            self.reloadButton.isHidden = true
            self.loader.isHidden = false
            self.postTableView.reloadData()
        }
    }
    
    func commentAction(post: Post, forCell cell: PostCell, showKeyboard: Bool) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
        vc.association = cell.association
        vc.post = post
        vc.showKeyboard = showKeyboard
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
            APIManager.dislikePost(post_id: post.id!, controller: self, completion: completion)
        }else{
            APIManager.likePost(post_id: post.id!, controller: self, completion: completion)
        }
    }
    
    func associationAction(association: Association) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AssociationViewController") as! AssociationViewController
        vc.association = association
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func scrollToTop(){
        self.postTableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchedText = self.searchBar.text {
            self.searchBar.resignFirstResponder()
            self.backgroundSearchView.isHidden = true
            self.searchBar.showsCancelButton = true
            self.searchViewController.search(keyword: searchedText)
            self.searchView.isHidden = false
        }
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
        self.backgroundSearchView.isHidden = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        self.backgroundSearchView.isHidden = true
        self.searchView.isHidden = true
    }
    
    @IBAction func dismissAction(_ sender: AnyObject) {
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func reloadAction(_ sender: AnyObject) {
        self.refreshUI(reload: true)
        self.fetchPosts()
    }
}
