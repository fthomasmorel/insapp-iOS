//
//  ListUserViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/30/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

protocol ListUserDelegate {
    func didTouchUser(_ user:User)
}

class ListUserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let fetchUserGroup = DispatchGroup()
    
    var delegate: ListUserDelegate?
    var userIds:[String] = []
    var users:[User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: kUserCell)
        self.tableView.tableFooterView = UIView()
        self.tableView.isHidden = true
    }
    
    func fetchUsers(){
        self.users = []
        for userId in self.userIds {
            DispatchQueue.global().async {
                self.fetchUserGroup.enter()
                APIManager.fetch(user_id: userId, controller: self, completion: { (user_opt) in
                    self.users.append(user_opt!)
                    self.fetchUserGroup.leave()
                })
            }
        }
        DispatchQueue.global().async {
            self.reloadUsers()
        }
    }
    
    func reloadUsers(){
        self.fetchUserGroup.wait()
        DispatchQueue.main.async {
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = self.users[indexPath.row]
        let cell = self.tableView.dequeueReusableCell(withIdentifier: kUserCell, for: indexPath) as! UserCell
        cell.load(user: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.users[indexPath.row]
        self.delegate?.didTouchUser(user)
    }
}
