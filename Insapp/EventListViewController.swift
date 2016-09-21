//
//  EventListViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/16/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class EventListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var eventLabel: UILabel!
    
    let fetchEventGroup = DispatchGroup()
    
    var fontColor: UIColor?
    var eventIds: [String] = []
    var events: [Event] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eventTableView.delegate = self
        self.eventTableView.dataSource = self
        self.eventTableView.register(UINib(nibName: "EventListCell", bundle: nil), forCellReuseIdentifier: kEventListCell)
        self.eventTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let color = self.fontColor {
            self.eventLabel.textColor = color
        }
    }
    
    func fetchEvents(){
        self.events = []
        for eventId in self.eventIds {
            DispatchQueue.global().async {
                self.fetchEventGroup.enter()
                APIManager.fetchEvent(event_id: eventId, controller: self, completion: { (opt_event) in
                    guard let event = opt_event else { return }
                    self.events.append(event)
                    self.fetchEventGroup.leave()
                })
            }
        }
        DispatchQueue.global().async {
            self.reloadEvents()
        }
    }
    
    func reloadEvents(){
        self.fetchEventGroup.wait()
        self.events = Event.sortAndFilter(events: self.events)
        DispatchQueue.main.async {
            self.eventTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = self.events[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: kEventListCell, for: indexPath) as! EventListCell
        cell.load(event: event, withColor: self.fontColor)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = self.events[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        vc.event = event
        self.parent?.navigationController?.pushViewController(vc, animated: true)
        
    }

    
}
