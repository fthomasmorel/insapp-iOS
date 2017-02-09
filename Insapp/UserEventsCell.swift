//
//  UserEventsCell.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 2/9/17.
//  Copyright © 2017 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

protocol UserEventsDelegate {
    func showAllEventAction()
    func show(event: Event, forAssociation association: Association)
}

let kUserEventsCell = "kUserEventsCell"

class UserEventsCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var events: [Event] = []
    var associations: [String : Association] = [:]
    var delegate: UserEventsDelegate?
    
    override func layoutSubviews() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(nibName: "EventListCell", bundle: nil), forCellReuseIdentifier: kEventListCell)
    }
    
    func load(events: [Event], forAssociations associations: [String : Association], isSelf: Bool) {
        self.events = events
        self.associations = associations
        if isSelf {
            self.titleLabel.text = "Mes Évènements"
        }else{
            self.titleLabel.text = "Évènements"
            self.events = Event.filter(events: self.events)
        }
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(3, self.events.count)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = self.events[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: kEventListCell, for: indexPath) as! EventListCell
        cell.load(event: event, withColor: .black)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = self.events[indexPath.row]
        let association = self.associations[event.association!]
        self.delegate?.show(event: event, forAssociation: association!)
    }
    
    static func getHeightForEvents(events: [Event], isSelf: Bool) -> CGFloat{
        var events = events
        if !isSelf {
            events = Event.filter(events: events)
        }
        return CGFloat(min(events.count, 3) * 60 + (events.count > 0 ? 47 + 30 : 0 ))
    }

    @IBAction func seeAllAction(_ sender: Any) {
        self.delegate?.showAllEventAction()
    }
}
