//
//  EventViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/14/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class EventViewController: UIViewController {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var associationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var attendeesLabel: UILabel!
    @IBOutlet weak var decisionControl: UISegmentedControl!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var event:Event!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.generateViewForEvent()
    }
    
    func generateViewForEvent(){
        self.view.backgroundColor = UIColor.hexToRGB(event.bgColor!)
        
        APIManager.fetchAssociation(association_id: event.association!) { (opt_asso) in
            guard let association = opt_asso else { return }
            self.associationLabel.text = "@\(association.name!.lowercased())"
        }
        
        self.coverImageView.downloadedFrom(link: kCDNHostname + event.photoURL!)
        self.computeGradient()
        self.titleLabel.text = event.name
        self.dateLabel.text = NSDate.stringForInterval(start: event.dateStart!, end: event.dateEnd!)
        self.attendeesLabel.text = "\(event.attendees!.count) participant\((event.attendees!.count > 1 ? "s" : ""))"
        self.descriptionTextView.text = event.desc
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
        self.backButton.setTitleColor(fontColor, for: .normal)

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
    
    
    @IBAction func dismissAction(_ sender: AnyObject) {
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func decisionDidChange(_ sender: AnyObject) {
        if self.decisionControl.selectedSegmentIndex == 0 {
            APIManager.participateToEvent(event_id: event.id!, completion: { (opt_event) in
                guard let event = opt_event else { self.triggerError("Can't not update status event") ; return }
                self.event = event
                self.generateViewForEvent()
            })
        }else{
            APIManager.dismissEvent(event_id: event.id!, completion: { (opt_event) in
                guard let event = opt_event else { self.triggerError("Can't not update status event") ; return }
                self.event = event
                self.generateViewForEvent()
            })
        }
    }
    
}
