//
//  EventCell.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/14/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class EventCell: UITableViewCell {
    
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var associationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var attendeesLabel: UILabel!
    
    var parent: UIViewController!
    
    func loadEvent(_ event: Event, forAssociation association: Association){
        self.eventImageView.downloadedFrom(link: kCDNHostname + event.photoURL!, contentMode: .scaleAspectFill, animated: false, completion: nil)
        self.associationLabel.text = "@\(association.name!.lowercased())"
        self.titleLabel.text = event.name
        self.dateLabel.text = NSDate.stringForInterval(start: event.dateStart!, end: event.dateEnd!, day: false)
        self.attendeesLabel.text = "\(event.attendees!.count) participant\((event.attendees!.count > 1 ? "s" : ""))"
    }
    
}
