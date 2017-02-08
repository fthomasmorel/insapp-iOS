//
//  AssociationContactCell.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 2/8/17.
//  Copyright © 2017 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

let kAssociationContactCell = "kAssociationContactCell"
class AssociationContactCell: UITableViewCell {
    
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var upperSeparator: UIView!
    @IBOutlet weak var lowerSeparator: UIView!
    
    func load(association: Association){
        let bgColor = UIColor.hexToRGB(association.bgColor!)
        let fgColor = UIColor.hexToRGB(association.fgColor!)
        
        self.contactLabel.text = "Contacter @" + association.name!.lowercased()
        self.contactLabel.textColor = fgColor
        self.upperSeparator.backgroundColor = fgColor
        self.lowerSeparator.backgroundColor = fgColor
        self.backgroundColor = bgColor
    }
    
}
