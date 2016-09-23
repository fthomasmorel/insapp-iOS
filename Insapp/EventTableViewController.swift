//
//  EventTableViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/14/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit



class EventTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var noEventLabel: UILabel!
    
    var events:[[Event]] = []
    var hasCurrentEvents = false
    var tableViewController = UITableViewController()
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: kEventCell)
        
        self.addChildViewController(self.tableViewController)
        self.tableViewController.tableView = self.tableView
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = UIColor.white.withAlphaComponent(0)
        self.refreshControl.addTarget(self, action: #selector(EventTableViewController.fetchEvents), for: UIControlEvents.valueChanged)
        self.tableViewController.refreshControl = self.refreshControl
        self.tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.notifyGoogleAnalytics()
        self.refreshUI(reload: true)
        self.lightStatusBar()
        self.fetchEvents()
    }
    
    func fetchEvents(){
        APIManager.fetchFutureEvents(controller: self) { (events) in
            let currentEvents = Event.filterCurrent(events: events)
            let comingEvents = Event.filterComing(events: events)
            
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
                self.events = [Event.sort(events: currentEvents), Event.sort(events: comingEvents)]
                self.hasCurrentEvents = true
            }
            self.refreshControl.endRefreshing()
            self.refreshUI()
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
        cell.parent = self
        cell.loadEvent(event)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = self.events[indexPath.section][indexPath.row]
        self.loadEvent(event: event)
    }
    
    func refreshUI(reload:Bool = false){
        if self.events.count == 0 {
            if reload {
                self.tableView.isHidden = true
                self.noEventLabel.isHidden = true
                self.reloadButton.isHidden = true
                self.loader.isHidden = false
            }else{
                self.tableView.isHidden = true
                self.noEventLabel.isHidden = false
                self.reloadButton.isHidden = false
                self.loader.isHidden = true
            }
        }else{
            self.tableView.isHidden = false
            self.noEventLabel.isHidden = true
            self.reloadButton.isHidden = true
            self.loader.isHidden = false
            self.tableView.reloadData()
        }
    }
    
    func loadEvent(event: Event){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        vc.event = event
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func reloadAction(_ sender: AnyObject) {
        self.refreshUI(reload: true)
        self.fetchEvents()
    }
}
