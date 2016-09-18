//
//  EventListCell.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/17/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class EventListCell: UITableViewCell{
    
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    func load(event: Event, withColor color: UIColor? = nil){
        self.eventImageView.downloadedFrom(link: kCDNHostname + event.photoURL!)
        self.dateLabel.text = NSDate.stringForInterval(start: event.dateStart!, end: event.dateEnd!, day: false)
        self.nameLabel.text = event.name
        self.backgroundColor = .clear
        
        if let color = color {
            self.separatorView.backgroundColor = color
            self.nameLabel.textColor = color
            self.dateLabel.textColor = color
        }
    }
    
}
