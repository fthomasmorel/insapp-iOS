//
//  EventDescriptionCell.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 2/6/17.
//  Copyright © 2017 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

let kEventDescriptionCell = "kEventDescriptionCell"

class EventDescriptionCell: UITableViewCell {
    
    @IBOutlet weak var contentTextView: UITextView!
    
    static func getHeight(width: CGFloat, forText text: String) -> CGFloat {
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width-16, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = UIFont(name: kNormalFont, size: 17)
        label.text = text + "\n\n\n"
        label.sizeToFit()
        return label.frame.height + 16 + 50
    }
    
}
