//
//  ListUserViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/30/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class ListUserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let fetchUserGroup = DispatchGroup()
    
    var userIds:[String] = []
    var users:[User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: kUserCell)
        self.tableView.tableFooterView = UIView()
        self.tableView.isHidden = true
        self.fetchUsers()
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
            self.reloadEvents()
        }
    }
    
    func reloadEvents(){
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
        vc.user_id = user.id
        vc.setEditable(false)
        vc.canReturn(true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func dismissAction(_ sender: AnyObject) {
        self.navigationController!.popViewController(animated: true)
    }
    
}
