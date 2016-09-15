//
//  EventTableViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/14/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

let kEventCell = "kEventCell"

class EventTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var events:[[Event]] = []
    var hasCurrentEvents = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: kEventCell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        APIManager.fetchFutureEvents { (events) in
            let currentEvents = events.filter({ (event) -> Bool in
                return event.dateStart!.timeIntervalSinceNow < 0
            })
            let comingEvents = events.filter({ (event) -> Bool in
                return event.dateStart!.timeIntervalSinceNow > 0
            })
            
            if currentEvents.count == 0 && comingEvents.count == 0{
                self.events = []
                self.hasCurrentEvents = false
            }else if currentEvents.count == 0 && comingEvents.count > 0 {
                self.events = [comingEvents]
                self.hasCurrentEvents = false
            }else if currentEvents.count > 0 && comingEvents.count == 0 {
                self.events = [currentEvents]
                self.hasCurrentEvents = true
            }else{
                self.events = [currentEvents, comingEvents]
                self.hasCurrentEvents = true
            }
            
            self.tableView.reloadData()
        }

    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.events.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return (self.hasCurrentEvents ? "En ce moment" : "À venir")
        default:
            return "À venir"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = self.events[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: kEventCell, for: indexPath) as! EventCell
        cell.loadEvent(event)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = self.events[indexPath.section][indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        vc.event = event
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
