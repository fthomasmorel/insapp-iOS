//
//  MeViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/13/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

let kWhiteEmptyCell = "kWhiteEmptyCell"

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UserEventsDelegate {
    
    @IBOutlet weak var optionButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var creditButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var promotionLabel: UILabel!
    
    var associations: [String : Association] = [:]
    var events: [Event] = []
    var user:User!
    var initialBrightness: CGFloat!
    
    var isEditable:Bool = true
    var canReturn:Bool = false
    var user_id:String!
    var hasLoaded = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(nibName: "UserEventsCell", bundle: nil), forCellReuseIdentifier: kUserEventsCell)
        self.tableView.register(UINib(nibName: "UserBarCodeCell", bundle: nil), forCellReuseIdentifier: kUserBarCodeCell)
        self.tableView.register(UINib(nibName: "UserDescriptionCell", bundle: nil), forCellReuseIdentifier: kUserDescriptionCell)
        self.tableView.register(UINib(nibName: "LoadingCell", bundle: nil), forCellReuseIdentifier: kLoadingCell)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: kWhiteEmptyCell)
        
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.width/2
        self.avatarImageView.layer.borderColor = UIColor.black.cgColor
        self.avatarImageView.layer.masksToBounds = true
        self.avatarImageView.layer.borderWidth = 1
        
        if self.user_id == nil {
            self.user_id = Credentials.fetch()!.userId
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.notifyGoogleAnalytics()
        self.lightStatusBar()
        self.hideNavBar()
        
        self.initialBrightness = UIScreen.main.brightness
        
        self.editButton.isHidden = !self.isEditable
        self.optionButton.isHidden = self.isEditable
        self.backButton.isHidden = !self.canReturn
        self.creditButton.isHidden = self.canReturn
        self.fetchUser(user_id: user_id)
    }
    
    func fetchUser(user_id:String){
        APIManager.fetch(user_id: user_id, controller: self) { (opt_user) in
            guard let user = opt_user else { return }
            self.user = user
            self.usernameLabel.text = "@" + self.user.username!
            self.nameLabel.text = self.user.name!
            self.emailLabel.text = self.user.email!
            self.promotionLabel.text = self.user.promotion!
            self.avatarImageView.image = self.user.avatar()
            self.fetchEvents()
            self.tableView.reloadData()
        }
    }
    
    func fetchEvents(){
        let group = DispatchGroup()
        self.events = []
        for eventId in self.user.events! {
            group.enter()
            APIManager.fetchEvent(event_id: eventId, controller: self, completion: { (opt_event) in
                guard let event = opt_event else { return }
                self.events.append(event)
                group.leave()
            })
        }
        
        group.notify(queue: DispatchQueue.main) {
            self.fetchAssociation()
        }
    }
    
    func fetchAssociation(){
        let group = DispatchGroup()
        for event in self.events {
            if self.associations[event.association!] == nil {
                group.enter()
                APIManager.fetchAssociation(association_id: event.association!, controller: self) { (opt_asso) in
                    guard let association = opt_asso else { return }
                    self.associations[event.association!] = association
                    group.leave()
                }
            }
        }
        group.notify(queue: DispatchQueue.main) {
            self.events = self.events.sorted(by: { (e1, e2) -> Bool in
                e1.dateStart!.timeIntervalSince(e2.dateStart! as Date) > 0
            })
            self.hasLoaded = true
            self.tableView.reloadData()
        }
    }

    
    func setEditable(_ editable:Bool){
        self.isEditable = editable
    }
    
    func canReturn(_ canReturn: Bool){
        self.canReturn = canReturn
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 { return 116 }
        let isSelf = self.user?.id == User.userInstance?.id
        if indexPath.row == 1 { return (self.hasLoaded ? 0 : 44) }
        if indexPath.row == 2 { return UserEventsCell.getHeightForEvents(events: self.events, isSelf: isSelf) }
        if indexPath.row == 3 { return UserBarCodeCell.getHeightForUser(user: self.user) }
        return UserDescriptionCell.getHeightForUser(self.user, forWidth: self.view.frame.width)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: kLoadingCell, for: indexPath) as! LoadingCell
            cell.loadUser()
            return cell
        }else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: kUserEventsCell, for: indexPath) as! UserEventsCell
            let isSelf = self.user?.id == User.userInstance?.id
            cell.load(events: self.events, forAssociations: self.associations, isSelf: isSelf)
            cell.delegate = self
            return cell
        }else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: kUserBarCodeCell, for: indexPath) as! UserBarCodeCell
            cell.load()
            return cell
        }else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: kUserDescriptionCell, for: indexPath) as! UserDescriptionCell
            cell.load(user: self.user)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: kWhiteEmptyCell, for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 3 {
            let brightness: CGFloat = UIScreen.main.brightness
            UIScreen.main.brightness = brightness == self.initialBrightness ? 1 : self.initialBrightness
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = max(0, scrollView.contentOffset.y)
        self.headerView.frame.origin.y = -max(0, value) + 80
        self.avatarImageView.bounds = CGRect(x: 0, y: 0, width: 100-value, height: 100-value)
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.width/2
    }
    
    func showAllEventAction(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserEventListViewController") as! UserEventListViewController
        let isSelf = self.user.id! == User.userInstance?.id!
        vc.events = ( isSelf ? self.events : Event.filter(events: self.events))
        vc.associations = self.associations
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func show(event: Event, forAssociation association: Association){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        vc.event = event
        vc.association = association
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func editAction(_ sender: AnyObject) {
        if !self.isEditable { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EditUserViewController") as! EditUserViewController
        vc.user = self.user
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func optionAction(_ sender: AnyObject) {
        let alertController = Alert.create(alert: .reportUser) { report in
            if report {
                APIManager.report(user: self.user, controller: self)
                let alert = Alert.create(alert: .reportConfirmation)
                self.present(alert, animated: true, completion: nil)
            }
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func creditAction(_ sender: AnyObject) {
        if self.canReturn { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CreditViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func dismissAction(_ sender: AnyObject) {
        self.navigationController!.popViewController(animated: true)
    }
}
