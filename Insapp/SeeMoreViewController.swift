//
//  SeeMoreViewController.swift
//  Insapp
//
//  Created by Guillaume Courtet on 21/12/2016.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import UIKit

class SeeMoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resultLabel: UILabel!
    
    var users: [User] = []
    var events: [Event] = []
    var posts: [Post] = []
    var associations: [Association] = []
    var searchedText: String!
    var type: Int!
    var prt: UniversalSearchViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.resultLabel.text = "\"\(searchedText!)\""
        
        self.tableView.register(UINib(nibName: "SearchUserCell", bundle: nil), forCellReuseIdentifier: kSearchUserCell)
        self.tableView.register(UINib(nibName: "SearchEventCell", bundle: nil), forCellReuseIdentifier: kSearchEventCell)
        self.tableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: kPostCell)
        self.tableView.register(UINib(nibName: "SearchPostCell", bundle: nil), forCellReuseIdentifier: kSearchPostCell)
        self.tableView.register(UINib(nibName: "SearchAssociationCell", bundle: nil), forCellReuseIdentifier: kSearchAssociationCell)
    }


    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (self.type) {
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            return self.events.count
        default:
            return self.users.count
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (self.type) {
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: kSearchAssociationCell, for: indexPath) as! SearchAssociationCell
                cell.parent = self.prt
                cell.more = 1
                cell.associations = self.associations
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: kSearchPostCell, for: indexPath) as! SearchPostCell
                cell.more = 1
                cell.parent = self.prt
                cell.loadPosts(self.posts)
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: kSearchEventCell, for: indexPath) as! SearchEventCell
                let event = self.events[indexPath.row]
                cell.load(event: event)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: kSearchUserCell, for: indexPath) as! SearchUserCell
                let user = self.users[indexPath.row]
                cell.loadUser(user: user)
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch self.type {
        case 1:
            let test = self.associations.count%3 == 0 ? self.associations.count/3 : self.associations.count/3 + 1
            let nb = CGFloat(test)
            let res = self.tableView.frame.width/3 * nb
            return res
        case 2:
            let test = self.posts.count%3 == 0 ? self.posts.count/3 : self.posts.count/3 + 1
            let nb = CGFloat(test)
            return self.tableView.frame.width/3 * nb
        case 3:
            return 70
        default:
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.type {
            case 1:
                return
            case 2:
                return
            case 3:
                let event = self.events[indexPath.row]
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
                vc.event = event
                self.prt.navigationController?.pushViewController(vc, animated: true)
            default:
                let user = self.users[indexPath.row]
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
                vc.user_id = user.id
                vc.setEditable(false)
                vc.canReturn(true)
                self.prt.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
 
    @IBAction func dismissAction(_ sender: AnyObject) {
        self.navigationController!.popViewController(animated: true)
    }
    
}
