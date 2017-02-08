//
//  AssociationViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/13/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class AssociationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AssociationPostsDelegate, AssociationEventsDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var eventListViewController: EventListViewController!
    var association: Association!
    var events:[Event] = []
    var posts:[Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "AssociationHeaderCell", bundle: nil), forCellReuseIdentifier: kAssociationHeaderCell)
        self.tableView.register(UINib(nibName: "AssociationPostsCell", bundle: nil), forCellReuseIdentifier: kAssociationPostsCell)
        self.tableView.register(UINib(nibName: "AssociationEventsCell", bundle: nil), forCellReuseIdentifier: kAssociationEventsCell)
        self.tableView.register(UINib(nibName: "AssociationDescriptionCell", bundle: nil), forCellReuseIdentifier: kAssociationDescriptionCell)
        self.tableView.register(UINib(nibName: "AssociationContactCell", bundle: nil), forCellReuseIdentifier: kAssociationContactCell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.hideNavBar()
        self.notifyGoogleAnalytics()
        self.tableView.backgroundColor = UIColor.hexToRGB(self.association.bgColor!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.fetchPosts()
        self.fetchEvents()
    }
    
    func fetchPosts(){
        let group = DispatchGroup()
        self.posts = []
        for postId in self.association.posts! {
            group.enter()
            APIManager.fetchPost(post_id: postId, controller: self, completion: { (opt_post) in
                guard let post = opt_post else { return }
                self.posts.append(post)
                group.leave()
            })
        }
        
        group.notify(queue: DispatchQueue.main) {
            self.posts = self.posts.sorted(by: { (p1, p2) -> Bool in
                p1.date!.timeIntervalSince(p2.date! as Date) > 0
            })
            self.tableView.reloadData()
        }
    }
    
    func fetchEvents(){
        let group = DispatchGroup()
        self.events = []
        for eventId in self.association.events! {
            group.enter()
            APIManager.fetchEvent(event_id: eventId, controller: self, completion: { (opt_event) in
                guard let event = opt_event else { return }
                self.events.append(event)
                group.leave()
            })
        }
        
        group.notify(queue: DispatchQueue.main) {
            self.events = self.events.sorted(by: { (e1, e2) -> Bool in
                e1.dateStart!.timeIntervalSince(e2.dateStart! as Date) > 0
            })
            self.tableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 0 }
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return .none }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 20))
        view.backgroundColor = UIColor.hexToRGB(self.association.bgColor!)
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 { return 233 }
        if indexPath.row == 0 { return AssociationEventsCell.getHeightForEvents(events: self.events) }
        if indexPath.row == 1 { return self.posts.count == 0 ? 0 : 225 + 30 }
        if indexPath.row == 2 { return AssociationDescriptionCell.getHeightForAssociation(association, forWidth: self.tableView.frame.width) }
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: kAssociationHeaderCell, for: indexPath) as! AssociationHeaderCell
            cell.load(association: self.association)
            cell.parent = self
            return cell
        }else{
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: kAssociationEventsCell, for: indexPath) as! AssociationEventsCell
                cell.load(events: self.events, forAssociation: self.association)
                cell.delegate = self
                return cell
            }else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: kAssociationPostsCell, for: indexPath) as! AssociationPostsCell
                cell.load(posts: self.posts, forAssociation: self.association)
                cell.delegate = self
                return cell
            }else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCell(withIdentifier: kAssociationDescriptionCell, for: indexPath) as! AssociationDescriptionCell
                cell.load(association: self.association)
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: kAssociationContactCell, for: indexPath) as! AssociationContactCell
                cell.load(association: self.association)
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1, indexPath.row == 3 {
            let email = self.association.email!
            let url = URL(string: "mailto:\(email)")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
    }
    
    func show(post: Post){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NewsViewController") as! NewsViewController
        vc.activePost = post
        vc.canReturn = true
        vc.canSearch = false
        vc.canRefresh = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showAllPostAction() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SeeMoreViewController") as! SeeMoreViewController
        vc.posts = self.posts
        vc.searchedText = "@" + self.association.name!
        vc.type = 2
        vc.prt = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func show(event: Event, association: Association){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        vc.event = event
        vc.association = association
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showAllEventAction(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SeeMoreViewController") as! SeeMoreViewController
        vc.events = self.events
        vc.associationTable = [ self.association.id! : self.association ]
        vc.searchedText = self.association.name!
        vc.type = 3
        vc.prt = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func dismissAction(_ sender: AnyObject) {
        self.navigationController!.popViewController(animated: true)
    }
}
