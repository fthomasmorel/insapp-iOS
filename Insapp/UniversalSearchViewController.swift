//
//  UniversalSearchViewControllerTableViewController.swift
//  Insapp
//
//  Created by Guillaume Courtet on 03/11/2016.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import UIKit

class UniversalSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var searchText: String!
    
    var associationTable:[String:Association] = [:]
    var users: [User]! = []
    var posts: [Post]! = []
    var associations: [Association]! = []
    var events: [Event]! = []
    var data: [[AnyObject]] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "SearchUserCell", bundle: nil), forCellReuseIdentifier: kSearchUserCell)
        self.tableView.register(UINib(nibName: "SearchEventCell", bundle: nil), forCellReuseIdentifier: kSearchEventCell)
        self.tableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: kPostCell)
        self.tableView.register(UINib(nibName: "SearchPostCell", bundle: nil), forCellReuseIdentifier: kSearchPostCell)
        self.tableView.register(UINib(nibName: "SearchAssociationCell", bundle: nil), forCellReuseIdentifier: kSearchAssociationCell)
        self.tableView.register(UINib(nibName: "SeeMoreCell", bundle: nil), forCellReuseIdentifier: kSeeMoreCell)
        self.tableView.tableFooterView = UIView()
        self.tableView.dataSource = self
        self.tableView.delegate = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
     
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        vw.backgroundColor = kLightGreyColor
        let label = UILabel(frame: .zero)
        label.text = "Section"
        label.font = UIFont(name: kBoldFont, size: 15.0)

        switch section {
        case 0:
            label.text = "Associations"
        case 1:
            label.text = "Posts"
        case 2:
            label.text = "Évènements"
        default:
            label.text = "Utilisateurs"
        }

        
        label.sizeToFit()
        label.frame.origin.x = 8
        vw.addSubview(label)
        return vw
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch  section {
        case 0:
            if (self.associations.count == 0) {
                return 1
            }
            return 1
        case 1:
            if (self.posts.count == 0) {
                return 1
            }
            if(self.posts.count > 6) {
                return 2
            }
            return 1
        case 2:
            if (self.events.count == 0) {
                return 1
            }
            if(self.events.count > 4) {
                return 5
            }
            return self.events.count
        default:
            if (self.users.count == 0) {
                return 1
            }
            if(self.users.count > 4) {
                return 5
            }
            return self.users.count
        }
    }
    
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    switch indexPath.section {
    case 0:
        if (self.associations.count == 0) {
            return 35
        }
        return 100
    case 1:
        if (self.posts.count == 0) {
            return 35
        }
        if(indexPath.row == 1 && self.posts.count > 6) {
            return 35
        }
        return tableView.frame.width/3 * (self.posts.count > 3 ? 2 : 1)
    case 2:
        if (self.events.count == 0) {
            return 35
        }
        if(indexPath.row == 4 && self.events.count > 5) {
            return 35
        }
        return 70
    default:
        if (self.users.count == 0) {
            return 35
        }
        if(indexPath.row == 4 && self.users.count > 5) {
            return 35
        }
        return 50
    }
    }
    
    func search(keyword: String){
        self.tableView.isHidden = true
        self.searchText = keyword
            
        APIManager.search(word: keyword, controller: self, completion: { (associations, users, events, posts) in
            
            let group = DispatchGroup()
            
            for event in events {
                if self.associationTable[event.association!] == nil {
                    group.enter()
                    APIManager.fetchAssociation(association_id: event.association!, controller: self) { (opt_asso) in
                        guard let association = opt_asso else { return }
                        self.associationTable[event.association!] = association
                        group.leave()
                    }
                }
            }
            
            for post in posts {
                if self.associationTable[post.association!] == nil {
                    group.enter()
                    APIManager.fetchAssociation(association_id: post.association!, controller: self) { (opt_asso) in
                        guard let association = opt_asso else { return }
                        self.associationTable[post.association!] = association
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: DispatchQueue.main, work: DispatchWorkItem(block: {
                DispatchQueue.main.async {
                    self.users = users
                    self.associations = associations
                    self.events = events
                    self.posts = posts
                    self.data = [associations,posts,events,users]
                    self.tableView.isHidden = false
                    self.tableView.reloadData()
                }
            }))

        })
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            if (self.associations.count == 0) {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: kSeeMoreCell, for: indexPath) as! SeeMoreCell
                cell.moreLabel.text = "Aucun résultat"
                cell.moreLabel.textAlignment = .center
                cell.moreLabel.textColor = kDarkGreyColor
                cell.selectionStyle = .none
                return cell
            } else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: kSearchAssociationCell, for: indexPath) as! SearchAssociationCell
            cell.parent = self
            cell.searchText = self.searchText
            cell.loadAssociations(self.associations)
            return cell
            }
        case 1:
            if (self.posts.count == 0) {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: kSeeMoreCell, for: indexPath) as! SeeMoreCell
                cell.moreLabel.text = "Aucun résultat"
                cell.moreLabel.textAlignment = .center
                cell.moreLabel.textColor = kDarkGreyColor
                cell.selectionStyle = .none
                return cell
            }
            if(indexPath.row == 1 && self.posts.count > 6){
                let cell = self.tableView.dequeueReusableCell(withIdentifier: kSeeMoreCell, for: indexPath) as! SeeMoreCell
                cell.moreLabel.text = "Voir plus de résultats"
                cell.moreLabel.textAlignment = .center
                cell.moreLabel.textColor = kDarkGreyColor
                cell.selectionStyle = .none
                return cell
            }
            else {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: kSearchPostCell, for: indexPath) as! SearchPostCell
                cell.parent = self
                cell.loadPosts(self.posts)
                return cell
            }
        case 2:
            if (self.events.count == 0) {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: kSeeMoreCell, for: indexPath) as! SeeMoreCell
                cell.moreLabel.text = "Aucun résultat"
                cell.moreLabel.textAlignment = .center
                cell.moreLabel.textColor = kDarkGreyColor
                cell.selectionStyle = .none
                return cell
            }
            if (indexPath.row == 4 && self.events.count > 5){
                let cell = self.tableView.dequeueReusableCell(withIdentifier: kSeeMoreCell, for: indexPath) as! SeeMoreCell
                cell.moreLabel.text = "Voir plus de résultats"
                cell.moreLabel.textAlignment = .center
                cell.moreLabel.textColor = kDarkGreyColor
                cell.selectionStyle = .none
                return cell
            }
            else {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: kSearchEventCell, for: indexPath) as! SearchEventCell
                cell.load(event: self.events[indexPath.row])
                return cell
            }
        default:
            if (self.users.count == 0) {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: kSeeMoreCell, for: indexPath) as! SeeMoreCell
                cell.moreLabel.text = "Aucun résultat"
                cell.moreLabel.textAlignment = .center
                cell.moreLabel.textColor = kDarkGreyColor
                cell.selectionStyle = .none
                return cell
            }
            if (indexPath.row == 4 && self.users.count > 5){
                let cell = self.tableView.dequeueReusableCell(withIdentifier: kSeeMoreCell, for: indexPath) as! SeeMoreCell
                cell.moreLabel.text = "Voir plus de résultats"
                cell.moreLabel.textAlignment = .center
                cell.moreLabel.textColor = kDarkGreyColor
                cell.selectionStyle = .none
                return cell
            }
            else {
                let user = self.users[indexPath.row]
                let cell = self.tableView.dequeueReusableCell(withIdentifier: kSearchUserCell, for: indexPath) as! SearchUserCell
                cell.loadUser(user: user)
                return cell
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            return
        case 1:
            if(indexPath.row == 1) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "SeeMoreViewController") as! SeeMoreViewController
                vc.posts = self.posts
                vc.searchedText = self.searchText
                vc.type = 2
                vc.prt = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                return
            }
        case 2:
            if (self.events.count == 0) {
                
            }
            else if(indexPath.row == 4 && self.events.count > 5) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "SeeMoreViewController") as! SeeMoreViewController
                vc.events = self.events
                vc.searchedText = self.searchText
                vc.type = 3
                vc.prt = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
            let event = self.events[indexPath.row]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
            vc.event = event
            self.parent?.navigationController?.pushViewController(vc, animated: true)
            }
        default:
            if (self.events.count == 0) {
                
            }
            else if(indexPath.row == 4 && self.users.count > 5) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "SeeMoreViewController") as! SeeMoreViewController
                vc.users = self.users
                vc.searchedText = self.searchText
                vc.type = 4
                vc.prt = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
            let user = self.users[indexPath.row]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
            vc.user_id = user.id
            vc.setEditable(false)
            vc.canReturn(true)
            self.parent?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }

}
