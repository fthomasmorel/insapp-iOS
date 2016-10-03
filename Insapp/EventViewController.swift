//
//  EventViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/14/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import EventKitUI
import EventKit
import UIKit

class EventViewController: UIViewController, EKEventEditViewDelegate {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var associationLabel: UILabel!
    @IBOutlet weak var dateLabel: UITextView!
    @IBOutlet weak var attendeesLabel: UILabel!
    @IBOutlet weak var decisionControl: UISegmentedControl!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var dateLabelHeightConstraint: NSLayoutConstraint!
    
    var event:Event!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.generateViewForEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.notifyGoogleAnalytics()
        self.changeStatusBarForColor(colorStr: event.fgColor)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(EventViewController.addToCalendarAction))
        self.dateLabel.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(EventViewController.showAttendeesAction))
        self.attendeesLabel.addGestureRecognizer(tap2)

    }
    
    func generateViewForEvent(){
        self.view.backgroundColor = UIColor.hexToRGB(event.bgColor!)
        
        APIManager.fetchAssociation(association_id: event.association!, controller: self) { (opt_asso) in
            guard let association = opt_asso else { return }
            self.associationLabel.text = "@\(association.name!.lowercased())"
        }

        self.coverImageView.downloadedFrom(link: kCDNHostname + self.event.photoURL!)
        self.computeGradient()
        self.titleLabel.text = self.event.name
        
        let dateString = NSDate.stringForInterval(start: self.event.dateStart!, end: self.event.dateEnd!)
        self.dateLabelHeightConstraint.constant = dateString.contains("\n") ? 50 : 25
        self.dateLabel.attributedText = NSAttributedString(string: dateString, attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])
        
        self.attendeesLabel.text = "\(self.event.attendees!.count) participant\((self.event.attendees!.count > 1 ? "s" : ""))"
        self.decisionControl.selectedSegmentIndex = 1
        if (User.fetch()!.events?.contains(self.event.id!))! {
            self.decisionControl.selectedSegmentIndex = 0
        }
        
        let fontColor = UIColor.hexToRGB(self.event.fgColor!)
        
        self.titleLabel.textColor = fontColor
        self.associationLabel.textColor = fontColor
        self.dateLabel.textColor = fontColor
        self.attendeesLabel.textColor = fontColor
        self.decisionControl.tintColor = fontColor
        self.descriptionTextView.textColor = fontColor
        self.descriptionTextView.linkTextAttributes = [NSForegroundColorAttributeName: fontColor, NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        
        let arrow = (self.event.fgColor! == "ffffff" ? UIImage(named: "arrow_left_white")! : UIImage(named: "arrow_left_black")!)
        self.backButton.setImage(arrow, for: .normal)
        
        self.descriptionTextView.text = self.event.desc
        self.descriptionTextView.isScrollEnabled = false
        self.descriptionTextView.isScrollEnabled = true
        self.descriptionTextView.scrollRangeToVisible(NSRange(location:0, length:0))
    }
    
    func computeGradient(){
        let opaqueColor = UIColor.hexToRGB(event.bgColor!)
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
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addToCalendarAction(){
        let eventController = EKEventEditViewController()
        let store = EKEventStore()
        eventController.eventStore = store
        eventController.editViewDelegate = self
        
        let event = EKEvent(eventStore: store)
        event.title = self.event.name!
        event.startDate = self.event.dateStart! as Date
        event.endDate = self.event.dateEnd! as Date
        event.notes = self.event.desc!
        eventController.event = event
        
        
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .authorized:
            DispatchQueue.main.async{
                self.present(eventController, animated: true, completion: self.darkStatusBar)
            }
        case .notDetermined:
            store.requestAccess(to: .event, completion: { (granted, error) -> Void in
                if !granted { return }
                DispatchQueue.main.async{
                    self.present(eventController, animated: true, completion: self.darkStatusBar)
                }
            })
        case .denied, .restricted:
            return
        }
    }
    
    func showAttendeesAction(){
        if let users = self.event.attendees, users.count > 0 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "AttendesViewController") as! AttendesViewController
            vc.userIds = users
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func askForSuggestion(){
        let alert = UIAlertController(title: "", message: "Souhaites-tu ajouter les évènements, auxquels tu participes, à ton calendrier ?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Non", style: .default, handler: { action in
            UserDefaults.standard.set(false, forKey: kSuggestCalendar)
        }))
        alert.addAction(UIAlertAction(title: "Oui", style: .default, handler: { action in
            UserDefaults.standard.set(true, forKey: kSuggestCalendar)
            self.addToCalendarAction()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func suggestAddCalendar(){
        guard let suggest = UserDefaults.standard.object(forKey: kSuggestCalendar) as? Bool else { self.askForSuggestion() ; return }
        if suggest { self.addToCalendarAction() }
    }
    
    
    
    @IBAction func dismissAction(_ sender: AnyObject) {
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func decisionDidChange(_ sender: AnyObject) {
        if self.decisionControl.selectedSegmentIndex == 0 {
            APIManager.participateToEvent(event_id: event.id!, controller: self, completion: { (opt_event) in
                guard let event = opt_event else { return }
                self.event = event
                self.generateViewForEvent()
            })
            self.suggestAddCalendar()
        }else{
            APIManager.dismissEvent(event_id: event.id!, controller: self, completion: { (opt_event) in
                guard let event = opt_event else { return }
                self.event = event
                self.generateViewForEvent()
            })
        }
    }
    
}
