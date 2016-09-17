//
//  AssociationViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/13/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class AssociationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var nextEventLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    let kAssociationEventCellView = "kAssociationEventCellView"
    let fetchEventGroup = DispatchGroup()
    
    var association: Association!
    var events:[Event]!
    var fontColor: UIColor!
    var viewNeverLoaded = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eventTableView.register(UITableViewCell.self, forCellReuseIdentifier: kAssociationEventCellView)
        self.eventTableView.dataSource = self
        self.eventTableView.delegate = self
        self.generateViewForAssociation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.fetchEvents()
    }
    
    func generateViewForAssociation(){
        self.coverImageView.downloadedFrom(link: kCDNHostname + self.association.coverPhotoURL!, contentMode: .scaleAspectFill, completion: { self.computeGradient() })
        self.fontColor = UIColor.hexToRGB(association.fgColor!)
        self.nameLabel.text = "@\(association.name!.lowercased())"
        self.nameLabel.textColor = self.fontColor
        self.descriptionTextView.text = association.desc
        self.descriptionTextView.textColor = self.fontColor
        self.computeHeightForDescription()
        self.nextEventLabel.textColor = self.fontColor
        self.view.backgroundColor = UIColor.hexToRGB(association.bgColor!)
        
        let arrow = (association.fgColor == "ffffff" ? UIImage(named: "arrow_left_white")! : UIImage(named: "arrow_left_black")!)
        self.backButton.setImage(arrow, for: .normal)
        
    }
    
    func computeHeightForDescription(){
        let frame = self.descriptionTextView.frame
        let height = self.descriptionTextView.contentSize.height
        self.descriptionTextView.isScrollEnabled = false
        self.descriptionTextView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: height)
    }
    
    func computeGradient(){
        let opaqueColor = UIColor.hexToRGB(association.bgColor!)
        let transColor = opaqueColor.withAlphaComponent(0)
        
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [opaqueColor.cgColor, transColor.cgColor]
        gradient.locations = [0 , 1]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 0.1)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.coverImageView.frame.size.width, height: 180)
        
        if let sublayers = self.coverImageView.layer.sublayers {
            for sublayer in sublayers {
                sublayer.removeFromSuperlayer()
            }
        }
        self.coverImageView.layer.insertSublayer(gradient, at: 0)
    }
    
    @IBAction func dismissAction(_ sender: AnyObject) {
        self.navigationController!.popViewController(animated: true)
    }
    
    func fetchEvents(){
        self.events = []
        for eventId in self.association.events! {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: kAssociationEventCellView, for: indexPath)
        
        self.generateCell(cell, forEvent: event)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = self.events[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
        vc.event = event
        self.navigationController?.pushViewController(vc, animated: true)
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
        nameLabel.textColor = self.fontColor
        
        let dateLabel = UILabel(frame: CGRect(x: 70, y: cell.frame.height-30, width: cell.frame.width-100, height: 20))
        dateLabel.text = NSDate.stringForInterval(start: event.dateStart!, end: event.dateEnd!, day: false)
        dateLabel.font = UIFont(name: kNormalFont, size: 13)
        dateLabel.textColor = self.fontColor
        
        let separator = UIView(frame: CGRect(x: 10, y: cell.frame.size.height-0.5, width: cell.frame.size.width-20, height: 0.5))
        separator.backgroundColor = self.fontColor
        
        cell.addSubview(imageView)
        cell.addSubview(nameLabel)
        cell.addSubview(dateLabel)
        cell.addSubview(separator)
    }
}
