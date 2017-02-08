//
//  EventHeaderCell.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 2/6/17.
//  Copyright © 2017 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

let kEventHeaderCell = "kEventHeaderCell"

enum EventStatus{
    case none
    case going
    case maybe
    case notgoing
}

enum ColorTheme{
    case dark
    case light
}

class EventHeaderCell: UITableViewCell {
        
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var associationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var clockImageView: UIImageView!
    @IBOutlet weak var attendeesLabel: UILabel!
    @IBOutlet weak var attendeeImageView: UIImageView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var goingLabel: UILabel!
    @IBOutlet weak var maybeLabel: UILabel!
    @IBOutlet weak var notgoingLabel: UILabel!
    @IBOutlet weak var goingImageView: UIImageView!
    @IBOutlet weak var unkownImageView: UIImageView!
    @IBOutlet weak var notgoingImageView: UIImageView!
    
    var event: Event!
    var theme: ColorTheme!
    var parent: EventViewController!
    var eventStatus: EventStatus = .none
    
    override func layoutSubviews() {
        self.dateView.layer.cornerRadius = 10
        self.dateView.layer.masksToBounds = true
        
        let tapShowAttendeesGesture1 = UITapGestureRecognizer(target: self, action: #selector(EventHeaderCell.showAttendees))
        let tapShowAttendeesGesture2 = UITapGestureRecognizer(target: self, action: #selector(EventHeaderCell.showAttendees))
        let tapAddToCalendar1 = UITapGestureRecognizer(target: self, action: #selector(EventHeaderCell.addToCalendar))
        let tapAddToCalendar2 = UITapGestureRecognizer(target: self, action: #selector(EventHeaderCell.addToCalendar))
        let tapAddToCalendar3 = UITapGestureRecognizer(target: self, action: #selector(EventHeaderCell.addToCalendar))
        let tapGoingGesture1 = UITapGestureRecognizer(target: self, action: #selector(EventHeaderCell.didTapGoing))
        let tapGoingGesture2 = UITapGestureRecognizer(target: self, action: #selector(EventHeaderCell.didTapGoing))
        let tapMaybeGesture1 = UITapGestureRecognizer(target: self, action: #selector(EventHeaderCell.didTapMaybe))
        let tapMaybeGesture2 = UITapGestureRecognizer(target: self, action: #selector(EventHeaderCell.didTapMaybe))
        let tapNotGoingGesture1 = UITapGestureRecognizer(target: self, action: #selector(EventHeaderCell.didTapNotGoing))
        let tapNotGoingGesture2 = UITapGestureRecognizer(target: self, action: #selector(EventHeaderCell.didTapNotGoing))
        
        self.attendeesLabel.addGestureRecognizer(tapShowAttendeesGesture1)
        self.attendeeImageView.addGestureRecognizer(tapShowAttendeesGesture2)
        self.dateView.addGestureRecognizer(tapAddToCalendar1)
        self.dayLabel.addGestureRecognizer(tapAddToCalendar2)
        self.monthLabel.addGestureRecognizer(tapAddToCalendar3)
        
        self.goingLabel.addGestureRecognizer(tapGoingGesture1)
        self.goingImageView.addGestureRecognizer(tapGoingGesture2)
        self.maybeLabel.addGestureRecognizer(tapMaybeGesture1)
        self.unkownImageView.addGestureRecognizer(tapMaybeGesture2)
        self.notgoingLabel.addGestureRecognizer(tapNotGoingGesture1)
        self.notgoingImageView.addGestureRecognizer(tapNotGoingGesture2)
    }
    
    func load(event: Event, association: Association){
        self.event = event
        
        let photo_url = kCDNHostname + event.photoURL!
        let fgColor = UIColor.hexToRGB(event.fgColor!)
        let bgColor = UIColor.hexToRGB(event.bgColor!)
        let monthName = event.dateStart!.monthName().uppercased()
        
        if event.fgColor == "ffffff" {
            self.theme = .light
            self.clockImageView.image = #imageLiteral(resourceName: "clock")
            self.attendeeImageView.image = #imageLiteral(resourceName: "attendee")
            self.goingImageView.image = #imageLiteral(resourceName: "go_light")
            self.unkownImageView.image = #imageLiteral(resourceName: "unkown_light")
            self.notgoingImageView.image = #imageLiteral(resourceName: "not_going_light")
            self.backButton.setImage(#imageLiteral(resourceName: "arrow_left_white"), for: .normal)
        }else{
            self.theme = .dark
            self.clockImageView.image = #imageLiteral(resourceName: "clock_dark")
            self.attendeeImageView.image = #imageLiteral(resourceName: "attendee_dark")
            self.goingImageView.image = #imageLiteral(resourceName: "go_dark")
            self.unkownImageView.image = #imageLiteral(resourceName: "unkown_dark")
            self.notgoingImageView.image = #imageLiteral(resourceName: "not_going_dark")
            self.backButton.setImage(#imageLiteral(resourceName: "arrow_left_black"), for: .normal)
        }
        
        self.eventImageView.downloadedFrom(link: photo_url)
        self.titleLabel.text = event.name
        self.titleLabel.textColor = fgColor
        self.associationLabel.text = "@\(association.name!)"
        self.associationLabel.textColor = fgColor
        
        let date = NSDate.stringForInterval(start: event.dateStart!, end: event.dateEnd!, day: true)
        self.dateLabel.text = date + (date.contains("\n") ? "" : "\n")
        self.dateLabel.textColor = fgColor
        self.attendeesLabel.text = "\(event.attendees!.count) participants"
        self.attendeesLabel.textColor = fgColor
        self.dateView.backgroundColor = fgColor
        self.dayLabel.text = "\(event.dateStart!.day())"
        self.dayLabel.textColor = bgColor
        self.monthLabel.text = "\(monthName.substring(to: monthName.index(monthName.startIndex, offsetBy: 3)))"
        self.monthLabel.textColor = bgColor
        self.backgroundColor = bgColor
        self.goingLabel.textColor = fgColor
        self.notgoingLabel.textColor = fgColor
        self.maybeLabel.textColor = fgColor
        
        if let contains = self.event.attendees?.contains(User.userInstance!.id!), contains {
            self.goingImageView.image = #imageLiteral(resourceName: "go_checked")
            self.eventStatus = .going
        }
        if let contains = self.event.maybe?.contains(User.userInstance!.id!), contains {
            self.unkownImageView.image = #imageLiteral(resourceName: "unkown_checked")
            self.eventStatus = .maybe
        }
        if let contains = self.event.notgoing?.contains(User.userInstance!.id!), contains {
            self.notgoingImageView.image = #imageLiteral(resourceName: "not_going_checked")
            self.eventStatus = .notgoing
        }
    }
    
    func addToCalendar() {
        self.parent.addToCalendarAction()
    }
    
    func showAttendees() {
        self.parent.showAttendeesAction()
    }
    
    func didTapGoing() {
        self.selectGoing()
        let status = self.eventStatus == .none ? "none" : "going"
        self.parent.changeStatus(status: status)
    }
    
    func didTapMaybe() {
        self.selectMaybe()
        let status = self.eventStatus == .none ? "none" : "maybe"
        self.parent.changeStatus(status: status)
    }
    
    func didTapNotGoing() {
        self.selectNotGoing()
        let status = self.eventStatus == .none ? "none" : "notgoing"
        self.parent.changeStatus(status: status)
    }
    
    func selectGoing(){
        if let activeImageView = self.getActiveStatusImageView(){
            if activeImageView == self.goingImageView {
                let theme = self.theme == .dark ? "dark" : "light"
                let image = UIImage(named: "go_\(theme).png")!
                self.animate(imageView: self.goingImageView, image: image)
                self.eventStatus = .none
                return
            }else{
                let name = self.eventStatus == .maybe ? "unkown" : "not_going"
                let theme = self.theme == .dark ? "dark" : "light"
                let image = UIImage(named: "\(name)_\(theme).png")!
                self.animate(imageView: activeImageView, image: image)
            }
        }
        self.eventStatus = .going
        self.animate(imageView: self.goingImageView, image: #imageLiteral(resourceName: "go_checked"))
    }
    
    func selectMaybe(){
        if let activeImageView = self.getActiveStatusImageView(){
            if activeImageView == self.unkownImageView {
                let theme = self.theme == .dark ? "dark" : "light"
                let image = UIImage(named: "unkown_\(theme).png")!
                self.animate(imageView: self.unkownImageView, image: image)
                self.eventStatus = .none
                return
            }else{
                let name = self.eventStatus == .going ? "go" : "not_going"
                let theme = self.theme == .dark ? "dark" : "light"
                let image = UIImage(named: "\(name)_\(theme).png")!
                self.animate(imageView: activeImageView, image: image)
            }
        }
        self.eventStatus = .maybe
        self.animate(imageView: self.unkownImageView, image: #imageLiteral(resourceName: "unkown_checked"))
    }
    
    func selectNotGoing(){
        if let activeImageView = self.getActiveStatusImageView(){
            if activeImageView == self.notgoingImageView {
                let theme = self.theme == .dark ? "dark" : "light"
                let image = UIImage(named: "not_going_\(theme).png")!
                self.animate(imageView: self.notgoingImageView, image: image)
                self.eventStatus = .none
                return
            }else{
                let name = self.eventStatus == .going ? "go" : "unkown"
                let theme = self.theme == .dark ? "dark" : "light"
                let image = UIImage(named: "\(name)_\(theme).png")!
                self.animate(imageView: activeImageView, image: image)
            }
        }
        self.eventStatus = .notgoing
        self.animate(imageView: self.notgoingImageView, image: #imageLiteral(resourceName: "not_going_checked"))
    }
    
    func animate(imageView: UIImageView, image: UIImage){
        let frame = imageView.frame
        UIView.animate(withDuration: 0.1, animations: {
            imageView.bounds = CGRect.zero
        }) { (finished) in
            imageView.image = image
            UIView.animate(withDuration: 0.1, animations: {
                imageView.frame = frame
            }, completion: { (finished) in
                
            })
        }
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.parent.dismissAction(sender as AnyObject)
    }
    
    func getActiveStatusImageView() -> UIImageView? {
        switch self.eventStatus {
        case .going:
            return self.goingImageView
        case .maybe:
            return self.unkownImageView
        case .notgoing:
            return notgoingImageView
        default:
            return .none
        }
    }
    
}
