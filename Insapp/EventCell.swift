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
    
    
    func loadEvent(_ event: Event){
        self.eventImageView.downloadedFrom(link: kCDNHostname + event.photoURL!)
        APIManager.fetchAssociation(association_id: event.association!) { (opt_asso) in
            guard let association = opt_asso else { return }
            self.associationLabel.text = "@\(association.name!.lowercased())"
        }
        self.titleLabel.text = event.name
        self.dateLabel.text = NSDate.stringForInterval(start: event.dateStart!, end: event.dateEnd!, day: false)
        self.attendeesLabel.text = "\(event.attendees!.count) participant\((event.attendees!.count > 1 ? "s" : ""))"
    }
    
}
