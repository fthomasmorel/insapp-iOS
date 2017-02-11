//
//  UserDescriptionCell.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 2/9/17.
//  Copyright © 2017 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

let kUserDescriptionCell = "kUserDescriptionCell"

class UserDescriptionCell: UITableViewCell {
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    func load(user: User?){
        if user != nil {
            self.descriptionTextView.text = user!.desc!
            self.descriptionTextView.linkTextAttributes = [NSForegroundColorAttributeName: UIColor.black, NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue];
        }
    }
    
    static func getHeightForUser(_ user: User?, forWidth width: CGFloat) -> CGFloat{
        if user == nil { return 0 }
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width-16, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = UIFont(name: kNormalFont, size: 17)
        label.text = user!.desc! + "\n\n\n"
        label.sizeToFit()
        return label.frame.height + CGFloat(16 + 47)
    }

}
