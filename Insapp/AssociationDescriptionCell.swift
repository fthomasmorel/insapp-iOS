//
//  AssociationDescriptionCell.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 2/7/17.
//  Copyright © 2017 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

let kAssociationDescriptionCell = "kAssociationDescriptionCell"

class AssociationDescriptionCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    func load(association: Association){
        self.backgroundColor = UIColor.hexToRGB(association.bgColor!)
        self.titleLabel.textColor = UIColor.hexToRGB(association.fgColor!)
        self.descriptionTextView.text = association.desc! + "\n\n\n"
        self.descriptionTextView.textColor = UIColor.hexToRGB(association.fgColor!)
    }
    
    static func getHeightForAssociation(_ association: Association, forWidth width: CGFloat) -> CGFloat{
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width-16, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = UIFont(name: kNormalFont, size: 17)
        label.text = association.desc! + "\n\n\n"
        label.sizeToFit()
        return label.frame.height + CGFloat(16 + 47)
    }
}
