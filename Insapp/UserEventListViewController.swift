//
//  UserEventListViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 2/9/17.
//  Copyright © 2017 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class UserEventListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var associations: [String : Association] = [:]
    var events:[Event] = []
    var futureEvents: [Event] = []
    var pastEvents: [Event] = []
    
    override func viewDidLoad() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "SearchEventCell", bundle: nil), forCellReuseIdentifier: kSearchEventCell)
        
        self.futureEvents = Event.filter(events: self.events)
        self.pastEvents = Event.filterPast(events: self.events)
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return "À Venir" }
        return "Passé"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return self.futureEvents.count }
        return self.pastEvents.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var event: Event!
        if indexPath.section == 0 {
            event = self.futureEvents[indexPath.row]
        }else{
            event = self.pastEvents[indexPath.row]
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: kSearchEventCell, for: indexPath) as! SearchEventCell
        cell.load(event: event)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        let event = (indexPath.section == 0 ? self.futureEvents[indexPath.row] : self.pastEvents[indexPath.row])
        vc.event = event
        vc.association = self.associations[event.association!]!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
