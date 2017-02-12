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
    var userIds:[[String]] = []
    var users:[[User]] = []
    
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
        for i in 0...self.userIds.count-1 {
            self.users.append([])
            for userId in self.userIds[i] {
                self.fetchUserGroup.enter()
                DispatchQueue.global().async {
                    APIManager.fetch(user_id: userId, controller: self, completion: { (user_opt) in
                        guard let user = user_opt else { self.fetchUserGroup.leave() ; return }
                        self.users[i].append(user)
                        self.fetchUserGroup.leave()
                    })
                }
            }
        }
        self.fetchUserGroup.notify(queue: DispatchQueue.main, work: DispatchWorkItem(block: {
            DispatchQueue.main.async {
                self.reloadUsers()
            }
        }))
    }
    
    func reloadUsers(){
        self.tableView.isHidden = false
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if users.count == 1 { return .none }
        switch section {
        case 0:
            return "J'y vais"
        case 1:
            return "Peut-être"
        default:
            return "J'y vais pas"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if users.count == 1 { return 0 }
        return self.users[section].count > 0 ? 20 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = self.users[indexPath.section][indexPath.row]
        let cell = self.tableView.dequeueReusableCell(withIdentifier: kUserCell, for: indexPath) as! UserCell
        cell.load(user: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.users[indexPath.section][indexPath.row]
        self.delegate?.didTouchUser(user)
    }
}
