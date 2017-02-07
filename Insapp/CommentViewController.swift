//
//  CommentViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/15/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

protocol CommentControllerDelegate {
    func comment(content: AnyObject, comment: Comment, completion: @escaping (AnyObject, String, NSDate, [Comment]) -> ())
    func uncomment(content: AnyObject, comment: Comment, completion: @escaping (AnyObject, String, NSDate, [Comment]) -> ())
    func report(content: AnyObject, comment: Comment)
}

class CommentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CommentViewDelegate, CommentCellDelegate {
    
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var commentTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var listUserView: UIView!
    @IBOutlet weak var heightConstraintUserViewController: NSLayoutConstraint!
    
    let fetchUserGroup = DispatchGroup()
    
    var listUserViewController:ListUserViewController!
    var users:[String:User]! = [:]
    var comments: [Comment]? = []
    var date: NSDate!
    var desc: String!
    var content: AnyObject!
    var association:Association!
    var commentView:CommentView!
    var keyboardFrame:CGRect!
    var showKeyboard = false
    var activeComment: Comment?
    var delegate: CommentControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commentTableView.delegate = self
        self.commentTableView.dataSource = self
        self.commentTableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: kCommentCell)
        self.commentTableView.tableFooterView = UIView()
        self.commentTableView.keyboardDismissMode = .interactive;
        self.fetchUsers()
        
        self.navigationController?.navigationBar.isHidden = true
        
        let frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 0)
        self.commentView = CommentView.instanceFromNib()
        self.commentView.initFrame(keyboardFrame: frame)
        self.commentView.delegate = self
        self.commentView.clearText()
        
        self.listUserViewController = self.childViewControllers.last as? ListUserViewController
        self.listUserViewController.delegate = self.commentView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        self.notifyGoogleAnalytics()
        self.lightStatusBar()
        self.hideTabBar()
        self.hideNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if showKeyboard {
            self.commentView.textView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: self.view.window)
        self.showTabBar()
    }
    
    override var inputAccessoryView: UIView {
        return self.commentView
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    func fetchUsers(){
        let users = Array(Set(self.comments!.map({ (comment) -> String in return comment.user_id! })))
        self.users = [:]
        for userId in users {
            self.fetchUserGroup.enter()
            DispatchQueue.global().async {
                APIManager.fetch(user_id: userId, controller: self, completion: { (opt_user) in
                    self.users[userId] = opt_user!
                    self.fetchUserGroup.leave()
                })
            }
        }
        self.fetchUserGroup.notify(queue: DispatchQueue.main) { 
            self.reload()
        }
    }
    
    func reload(){
        self.commentTableView.reloadData()
        if let comment = self.activeComment, let row = self.comments?.index(of: comment){
            let indexPath = IndexPath(row: row+1, section: 0)
            self.commentTableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
        }else{
            self.scrollToBottom()
        }
    }

    func scrollToBottom(_ animated: Bool = true){
        let numberOfRows = self.commentTableView.numberOfRows(inSection: 0)
        if numberOfRows > 0 {
            let indexPath = IndexPath(row: numberOfRows-1, section: 0)
            self.commentTableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: animated)
        }
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
        self.keyboardFrame = (userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue).cgRectValue
        DispatchQueue.main.async {
            self.commentTableView.contentInset = UIEdgeInsetsMake(0, 0, self.keyboardFrame.height - (kCommentEmptyTextViewHeight + kCommentViewEmptyHeight), 0)
            self.commentTableView.scrollIndicatorInsets = self.commentTableView.contentInset
            self.scrollToBottom(false)
        }

    }
    
    func keyboardWillChangeFrame(_ notification: NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        self.keyboardFrame = (userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue).cgRectValue
        self.commentTableView.contentInset = .zero
        self.commentTableView.scrollIndicatorInsets = .zero
    }

    func postComment(_ content: String, withTags tags: [CommentTag]) {
        let user_id = User.fetch()!.id!
        let comment = Comment(comment_id: "", user_id: user_id, content: content, date: NSDate())
        comment.tags = tags
        self.delegate?.comment(content: self.content, comment: comment, completion: { (content, description, date, comments) in
            DispatchQueue.main.async {
                self.comments = comments
                self.desc = description
                self.content = content
                self.date = date
                self.fetchUsers()
                self.commentTableView.reloadData()
                self.commentView.resignFirstResponder()
            }
        })
    }
    
    func searchForUser(_ word: String) {
        if word.characters.count > 0 {
            APIManager.searchUser(word: word, controller: self) { (users) in
                if users.count > 0 {                    
                    self.listUserView.isHidden = false
                    self.listUserViewController.users = [users]
                    self.listUserViewController.reloadUsers()
                    self.listUserViewController.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.keyboardFrame.height - (kCommentEmptyTextViewHeight + kCommentViewEmptyHeight), 0)
                }else{
                    self.listUserViewController.users = []
                    self.listUserViewController.reloadUsers()
                    self.listUserViewController.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.keyboardFrame.height - (kCommentEmptyTextViewHeight + kCommentViewEmptyHeight), 0)
                }
            }
        }else{
            self.listUserView.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: kCommentCell) as! CommentCell
            cell.parent = self
            cell.preloadAssociationComment(association: self.association, forText: self.desc, atDate: self.date)
            let textView = cell.viewWithTag(2) as! UITextView
            return (textView.contentSize.height + CGFloat(kCommentCellEmptyHeight))
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: kCommentCell) as! CommentCell
            cell.parent = self
            cell.preloadUserComment(self.comments![indexPath.row-1])
            let textView = cell.viewWithTag(2) as! UITextView
            return (textView.contentSize.height + CGFloat(kCommentCellEmptyHeight))
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.users.count == 0 ? 0 : self.comments!.count) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return generateDescriptionCell(indexPath)
        }
        return generateCommentCell(indexPath)
    }
    
    func generateDescriptionCell(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = self.commentTableView.dequeueReusableCell(withIdentifier: kCommentCell, for: indexPath) as! CommentCell
        cell.parent = self
        cell.loadAssociationComment(association: self.association, forText: self.desc, atDate: self.date)
        cell.delegate = self
        return cell
    }
    
    func generateCommentCell(_ indexPath: IndexPath) -> UITableViewCell {
        let comment = self.comments![indexPath.row-1]
        let user = self.users[comment.user_id!]!
        let cell = self.commentTableView.dequeueReusableCell(withIdentifier: kCommentCell, for: indexPath) as! CommentCell
        cell.parent = self
        cell.loadUserComment(comment, user: user)
        cell.delegate = self
        
        if comment.id! == self.activeComment?.id! {
            cell.frontView.backgroundColor = kLightGreyColor
        }else{
            cell.frontView.backgroundColor = .white
        }
        
        return cell
    }
    
    func report(comment: Comment){
        let alertController = Alert.create(alert: .reportComment) { report in
            if report {
                self.delegate?.report(content: self.content, comment: comment)
                let alert = Alert.create(alert: .reportConfirmation)
                self.present(alert, animated: true, completion: nil)
            }
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func delete(comment: Comment) {
        self.delegate?.uncomment(content: self.content, comment: comment, completion: { (content, description, date, comments) in
            DispatchQueue.main.async {
                self.comments = comments
                self.desc = description
                self.content = content
                self.date = date
                self.commentTableView.reloadData()
                self.commentView.clearText()
            }
        })
    }
    
    func open(user: User) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
        vc.user_id = user.id
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
        self.navigationController!.popViewController(animated: true)
    }
}
