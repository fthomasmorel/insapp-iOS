//
//  EventViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/14/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import EventKitUI
import EventKit
import UIKit

class EventViewController: UIViewController, EKEventEditViewDelegate, UITableViewDelegate, UITableViewDataSource, EventTabDelegate, CommentControllerDelegate, CommentCellDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    var index = 0
    var event: Event!
    var association: Association!
    var eventTabView: EventTabView!
    var users: [String: User] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "EventHeaderCell", bundle: nil), forCellReuseIdentifier: kEventHeaderCell)
        self.tableView.register(UINib(nibName: "EventDescriptionCell", bundle: nil), forCellReuseIdentifier: kEventDescriptionCell)
        self.tableView.register(UINib(nibName: "EventCommentCell", bundle: nil), forCellReuseIdentifier: kEventCommentCell)
        self.tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: kCommentCell)
        
        
        self.eventTabView = Bundle.main.loadNibNamed("EventTabView", owner: self, options: nil)?[0] as! EventTabView
        self.eventTabView.statusBarView.backgroundColor = UIColor.hexToRGB(self.event.bgColor!)
        self.eventTabView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.hideNavBar()
        self.notifyGoogleAnalytics()
        self.changeStatusBarForColor(colorStr: event.fgColor)
        self.fetchUsers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.reloadView()
    }
    
    func fetchUsers(){
        let users = Array(Set(self.event.comments!.map({ (comment) -> String in return comment.user_id! })))
        let group = DispatchGroup()
        self.users = [:]
        for userId in users {
            group.enter()
            DispatchQueue.global().async {
                APIManager.fetch(user_id: userId, controller: self, completion: { (opt_user) in
                    self.users[userId] = opt_user!
                    group.leave()
                })
            }
        }
        group.notify(queue: DispatchQueue.main) { 
            self.reloadView()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 0 }
        return 70
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return .none }
        self.eventTabView.updateIndex(index: self.index)
        return self.eventTabView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        let commentCount = (self.users.count == 0 ? 0 : event.comments!.count)
        return ( self.index == 0 ? 1 : commentCount + 1)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { return 410 }
        let descriptionHeight = EventDescriptionCell.getHeight(width: self.view.frame.width, forText: self.event.desc!)
        if self.index == 0 { return descriptionHeight }
        if indexPath.row == 0 { return 71 }
        let cell = tableView.dequeueReusableCell(withIdentifier: kCommentCell) as! CommentCell
        cell.parent = self
        cell.preloadUserComment(self.event.comments![indexPath.row-1])
        let textView = cell.viewWithTag(2) as! UITextView
        return (textView.contentSize.height + CGFloat(kCommentCellEmptyHeight))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: kEventHeaderCell, for: indexPath) as! EventHeaderCell
            cell.parent = self
            cell.load(event: self.event, association: self.association)
            return cell
        }
        if self.index == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: kEventCommentCell, for: indexPath) as! EventCommentCell
                cell.avatarImageView.image = User.userInstance?.avatar()
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: kCommentCell, for: indexPath) as! CommentCell
                let comment = self.event.comments![indexPath.row-1]
                let user = self.users[comment.user_id!]!
                cell.delegate = self
                cell.loadUserComment(comment, user: user)
                return cell
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kEventDescriptionCell, for: indexPath) as! EventDescriptionCell
        cell.contentTextView.text = self.event.desc! + "\n\n\n\n"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1, indexPath.row == 0, self.index == 1 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CommentViewController") as! CommentViewController
            vc.comments = self.event.comments
            vc.association = self.association
            vc.desc = self.event.desc!
            vc.date = NSDate()
            vc.content = self.event
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func report(comment: Comment){
         APIManager.report(comment: comment, event: self.event, controller: self)
    }
    
    func delete(comment: Comment){
        APIManager.uncomment(event_id: self.event.id!, comment_id: comment.id!, controller: self, completion: { (opt_event) in
            guard let event = opt_event else { return }
            self.event = event
            self.reloadView()
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
    
    func comment(content: AnyObject, comment: Comment, completion: @escaping (AnyObject, String, NSDate, [Comment]) -> ()){
        APIManager.comment(event_id: (content as! Event).id!, comment: comment, controller: self) { (opt_event) in
            guard let event = opt_event else { return }
            self.event = event
            completion(event, event.desc!, NSDate(), event.comments!)
        }
    }
    
    func uncomment(content: AnyObject, comment: Comment, completion: @escaping (AnyObject, String, NSDate, [Comment]) -> ()){
        APIManager.uncomment(event_id: (content as! Event).id!, comment_id: comment.id!, controller: self, completion: { (opt_event) in
            guard let event = opt_event else { return }
            self.event = event
            completion(event, event.desc!, NSDate(), event.comments!)
        })
    }
    
    func report(content: AnyObject, comment: Comment){
        APIManager.report(comment: comment, event: (content as! Event), controller: self)
    }

    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func indexDidChange(index: Int) {
        self.index = index
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
        self.reloadView()
    }
    
    func changeStatus(status: String){
        if status != "none" {
            APIManager.changeStatusForEvent(event_id: self.event.id!, status: status, controller: self, completion: { (opt_event) in
                guard let event = opt_event else { return }
                self.event = event
                self.reloadView()
            })
        }else{
            APIManager.dismissEvent(event_id: self.event.id!, controller: self, completion: { (opt_event) in
                guard let event = opt_event else { return }
                self.event = event
                self.reloadView()
            })
        }
    }
    
    func addToCalendarAction(){
        let eventController = EKEventEditViewController()
        let store = EKEventStore()
        eventController.eventStore = store
        eventController.editViewDelegate = self
        
        let event = EKEvent(eventStore: store)
        event.title = self.event.name!
        event.startDate = self.event.dateStart! as Date
        event.endDate = self.event.dateEnd! as Date
        event.notes = self.event.desc!
        eventController.event = event
        
        
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .authorized:
            DispatchQueue.main.async{
                self.present(eventController, animated: true, completion: self.darkStatusBar)
            }
        case .notDetermined:
            store.requestAccess(to: .event, completion: { (granted, error) -> Void in
                if !granted {
                    
                }
                DispatchQueue.main.async{
                    self.present(eventController, animated: true, completion: self.darkStatusBar)
                }
            })
        case .denied, .restricted:
            let alert = Alert.create(alert: .calendarAuthorization)
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func showAttendeesAction(){
        guard let going = self.event.attendees,
            let maybe = self.event.maybe,
            let notgoing = self.event.notgoing,
            going.count > 0 || maybe.count > 0 || notgoing.count > 0 else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AttendesViewController") as! AttendesViewController
        vc.going = going
        vc.maybe = maybe
        vc.notgoing = notgoing
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func askForSuggestion(){
        let alert = Alert.create(alert: .eventAdding) { (success) in
            if success {
                UserDefaults.standard.set(true, forKey: kSuggestCalendar)
                self.addToCalendarAction()
            }else{
                UserDefaults.standard.set(false, forKey: kSuggestCalendar)
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func suggestAddCalendar(){
        guard let suggest = UserDefaults.standard.object(forKey: kSuggestCalendar) as? Bool else { self.askForSuggestion() ; return }
        if suggest { self.addToCalendarAction() }
    }
    
    func reloadView(){
        self.event.comments = self.event.comments?.sorted(by: { (commentA, commentB) -> Bool in
            return commentA.date!.timeIntervalSince(commentB.date! as Date) > 0
        })
        self.tableView.reloadData()
    }
    
    @IBAction func dismissAction(_ sender: AnyObject) {
        self.navigationController!.popViewController(animated: true)
    }
    
}
