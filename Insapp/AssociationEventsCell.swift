//
//  AssociationEventsCell.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 2/7/17.
//  Copyright © 2017 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

let kAssociationEventsCell = "kAssociationEventsCell"

protocol AssociationEventsDelegate {
    func show(event: Event, association: Association)
    func showAllEventAction()
}
class AssociationEventsCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var events: [Event] = []
    var association: Association!
    var delegate: AssociationEventsDelegate?
    
    override func layoutSubviews() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.register(UINib(nibName: "EventListCell", bundle: nil), forCellReuseIdentifier: kEventListCell)
    }
    
    func load(events: [Event], forAssociation association: Association) {
        self.events = events
        self.association = association
        self.backgroundColor = UIColor.hexToRGB(self.association.bgColor!)
        self.seeAllButton.setTitleColor(UIColor.hexToRGB(self.association.fgColor!), for: .normal)
        self.titleLabel.textColor = UIColor.hexToRGB(self.association.fgColor!)
        self.tableView.backgroundColor = UIColor.hexToRGB(self.association.bgColor!)
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
        cell.load(event: event, withColor: UIColor.hexToRGB(self.association.fgColor!))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = self.events[indexPath.row]
        self.delegate?.show(event: event, association: self.association)
    }
    
    @IBAction func seeAllAction(_ sender: Any) {
        self.delegate?.showAllEventAction()
    }
    
    static func getHeightForEvents(events: [Event]) -> CGFloat{
        return CGFloat(min(events.count, 3) * 60 + (events.count > 0 ? 47 + 30 : 0 ))
    }
}
