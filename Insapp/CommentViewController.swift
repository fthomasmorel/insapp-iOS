//
//  CommentViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/15/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class CommentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CommentViewDelegate, CommentCellDelegate {
    
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var commentTableViewHeightConstraint: NSLayoutConstraint!
    
    var post:Post!
    var association:Association!
    
    
    var commentView:CommentView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commentTableView.delegate = self
        self.commentTableView.dataSource = self
        self.commentTableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: kCommentCell)
        self.commentTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        self.hideTabBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 0)
        self.commentView = CommentView.instanceFromNib()
        self.commentView.initFrame(keyboardFrame: frame)
        self.commentView.delegate = self
        self.view.addSubview(self.commentView)
        self.commentTableView.scrollToRow(at: IndexPath(row: self.post.comments!.count, section: 0), at: .top, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
    }
    
    func hideTabBar(){
        UIView.animate(withDuration: 0.25, animations: { 
            self.tabBarController?.tabBar.frame.origin.y = self.view.frame.height
        })
    }
    
    func showTabBar(){
        UIView.animate(withDuration: 0.25, animations: {
            self.tabBarController?.tabBar.frame.origin.y = self.view.frame.height - (self.tabBarController?.tabBar.frame.size.height)!
        })
    }
    
    func keyboardWillShow(_ notification: NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame = (userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue).cgRectValue
        self.commentView.initFrame(keyboardFrame: keyboardFrame)
        self.commentView.isHidden = false
    }

    
    func postComment(_ content: String) {
        let user_id = User.fetch()!.id!
        let comment = Comment(comment_id: "", user_id: user_id, content: content, date: NSDate())
        APIManager.comment(post_id: self.post.id!, comment: comment) { (opt_post) in
            guard let post = opt_post else { return }
            self.post = post
            DispatchQueue.main.async {
                self.commentTableView.reloadData()
                self.commentView.clearText()
            }
        }
    }
    
    func updateFrame(_ frame: CGRect) {
        self.commentView.frame = frame
        self.commentTableViewHeightConstraint.constant = self.view.frame.height - frame.origin.y - frame.size.height
        self.updateViewConstraints()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: kCommentCell) as! CommentCell
            cell.preloadAssociationComment(association: self.association, forPost: self.post)
            let textView = cell.viewWithTag(2) as! UITextView
            return (textView.contentSize.height + CGFloat(kCommentCellEmptyHeight))
         
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: kCommentCell) as! CommentCell
            cell.preloadUserComment(self.post.comments![indexPath.row-1])
            let textView = cell.viewWithTag(2) as! UITextView
            return (textView.contentSize.height + CGFloat(kCommentCellEmptyHeight))
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.post.comments!.count+1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return generateDescriptionCell(indexPath)
        }
        return generateCommentCell(indexPath)
    }
    
    func generateDescriptionCell(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = self.commentTableView.dequeueReusableCell(withIdentifier: kCommentCell, for: indexPath) as! CommentCell
        cell.loadAssociationComment(association: self.association, forPost: self.post)
        cell.delegate = self
        return cell
    }
    
    func generateCommentCell(_ indexPath: IndexPath) -> UITableViewCell {
        let comment = self.post.comments![indexPath.row-1]
        let cell = self.commentTableView.dequeueReusableCell(withIdentifier: kCommentCell, for: indexPath) as! CommentCell
        cell.loadUserComment(comment)
        cell.delegate = self
        return cell
    }
    
    func delete(comment: Comment) {
        APIManager.uncomment(post_id: self.post.id!, comment_id: comment.id!, completion: { (opt_post) in
            guard let post = opt_post else { return }
            self.post = post
            DispatchQueue.main.async {
                self.commentTableView.reloadData()
                self.commentView.clearText()
            }
        })
    }
    
    func open(user: User) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
        vc.user = user
        vc.setEditable(false)
        vc.canReturn(true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func open(association: Association){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AssociationViewController") as! AssociationViewController
        vc.association = association
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func dismissAction(_ sender: AnyObject) {
        self.showTabBar()
        self.navigationController!.popViewController(animated: true)
    }
}
