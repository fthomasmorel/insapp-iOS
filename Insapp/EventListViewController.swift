//
//  EventListViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/16/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

let kEventListCell = "kEventListCell"

class EventListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var eventTableView: UITableView!

    let fetchEventGroup = DispatchGroup()
    
    var user: User!
    var events: [Event]! = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eventTableView.delegate = self
        self.eventTableView.dataSource = self
        self.eventTableView.register(UITableViewCell.self, forCellReuseIdentifier: kEventListCell)
    }
    
    func fetchEvents(){
        self.events = []
        for eventId in self.user.events! {
            DispatchQueue.global().async {
                self.fetchEventGroup.enter()
                APIManager.fetchEvent(event_id: eventId, completion: { (opt_event) in
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
        let cell = tableView.dequeueReusableCell(withIdentifier: kEventListCell, for: indexPath)
        
        self.generateCell(cell, forEvent: event)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = self.events[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        vc.event = event
        self.parent?.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func generateCell(_ cell: UITableViewCell, forEvent event:Event){
        cell.selectionStyle = .none
        cell.backgroundColor = cell.backgroundColor?.withAlphaComponent(0)
        
        for subview in cell.subviews {
            subview.removeFromSuperview()
        }
        
        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 40, height: 40))
        imageView.downloadedFrom(link: kCDNHostname + event.photoURL!)
        imageView.clipsToBounds = true
        
        let nameLabel = UILabel(frame: CGRect(x: 70, y: 10, width: cell.frame.width-100, height: 20))
        nameLabel.text = event.name
        nameLabel.font = UIFont(name: kBoldFont, size: 15)
        
        let dateLabel = UILabel(frame: CGRect(x: 70, y: cell.frame.height-30, width: cell.frame.width-100, height: 20))
        dateLabel.text = NSDate.stringForInterval(start: event.dateStart!, end: event.dateEnd!, day: false)
        dateLabel.font = UIFont(name: kNormalFont, size: 13)
        
        let separator = UIView(frame: CGRect(x: 10, y: cell.frame.size.height-0.5, width: cell.frame.size.width-20, height: 0.5))
        
        cell.addSubview(imageView)
        cell.addSubview(nameLabel)
        cell.addSubview(dateLabel)
        cell.addSubview(separator)
    }

    
}
