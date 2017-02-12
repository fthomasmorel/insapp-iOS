//
//  SearchEventCellCell.swift
//  Insapp
//
//  Created by Guillaume Courtet on 22/11/2016.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import UIKit

class SearchEventCell: UITableViewCell {

    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func load(event: Event){
        eventImage.contentMode = .scaleAspectFill
        eventImage.clipsToBounds = true
        self.eventImage.downloadedFrom(link: kCDNHostname + event.photoURL!)
        self.eventDate.text = NSDate.stringForInterval(start: event.dateStart!, end: event.dateEnd!, day: false)
        self.eventName.text = event.name
        self.backgroundColor = .clear
        self.eventDate.textColor = UIColor(red:0.47, green:0.47, blue:0.47, alpha:1.0)
    }
}
