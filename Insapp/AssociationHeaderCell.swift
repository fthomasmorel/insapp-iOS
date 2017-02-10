//
//  AssociationHeaderCell.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 2/7/17.
//  Copyright © 2017 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

let kAssociationHeaderCell = "kAssociationHeaderCell"
class AssociationHeaderCell: UITableViewCell {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    var parent: AssociationViewController!
    
    func load(association: Association){
        let fgColor = UIColor.hexToRGB(association.fgColor!)
        let bgColor = UIColor.hexToRGB(association.bgColor!)
        
        self.nameLabel.text = "@" + association.name!
        self.nameLabel.textColor = fgColor
        self.backgroundColor = bgColor
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.parent.dismissAction(sender as AnyObject)
    }
    
}
