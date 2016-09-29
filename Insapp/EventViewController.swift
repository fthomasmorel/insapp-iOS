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
        self.descriptionTextView.text = event.desc
        self.descriptionTextView.scrollRangeToVisible(NSRange(location:0, length:0))
        let tap = UITapGestureRecognizer(target: self, action: #selector(EventViewController.addToCalendarAction))
        self.dateLabel.addGestureRecognizer(tap)
    }
    
    func generateViewForEvent(){
        self.view.backgroundColor = UIColor.hexToRGB(event.bgColor!)
        
        APIManager.fetchAssociation(association_id: event.association!, controller: self) { (opt_asso) in
            guard let association = opt_asso else { return }
            self.associationLabel.text = "@\(association.name!.lowercased())"
        }
        
        self.coverImageView.downloadedFrom(link: kCDNHostname + event.photoURL!)
        self.computeGradient()
        self.titleLabel.text = event.name
        
        let dateString = NSDate.stringForInterval(start: event.dateStart!, end: event.dateEnd!)
        self.dateLabelHeightConstraint.constant = dateString.contains("\n") ? 50 : 25
        self.dateLabel.attributedText = NSAttributedString(string: dateString, attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])
        
        self.attendeesLabel.text = "\(event.attendees!.count) participant\((event.attendees!.count > 1 ? "s" : ""))"
        self.decisionControl.selectedSegmentIndex = 1
        if (User.fetch()!.events?.contains(self.event.id!))! {
            self.decisionControl.selectedSegmentIndex = 0
        }
        
        let fontColor = UIColor.hexToRGB(event.fgColor!)
        
        self.titleLabel.textColor = fontColor
        self.associationLabel.textColor = fontColor
        self.dateLabel.textColor = fontColor
        self.attendeesLabel.textColor = fontColor
        self.decisionControl.tintColor = fontColor
        self.descriptionTextView.textColor = fontColor
        self.descriptionTextView.linkTextAttributes = [NSForegroundColorAttributeName: fontColor, NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        
        let arrow = (event.fgColor! == "ffffff" ? UIImage(named: "arrow_left_white")! : UIImage(named: "arrow_left_black")!)
        self.backButton.setImage(arrow, for: .normal)
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
        }else{
            APIManager.dismissEvent(event_id: event.id!, controller: self, completion: { (opt_event) in
                guard let event = opt_event else { return }
                self.event = event
                self.generateViewForEvent()
            })
        }
    }
    
}
