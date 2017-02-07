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
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var parent: AssociationViewController!
    
    override func layoutSubviews() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width/2
        self.profileImageView.layer.masksToBounds = true
    }
    
    func load(association: Association){
        let coverURL = kCDNHostname + association.coverPhotoURL!
        let profileURL = kCDNHostname + association.profilePhotoURL!
        let fgColor = UIColor.hexToRGB(association.fgColor!)
        let bgColor = UIColor.hexToRGB(association.bgColor!)
        
        self.coverImageView.downloadedFrom(link: coverURL)
        self.profileImageView.downloadedFrom(link: profileURL)
        self.nameLabel.text = "@" + association.name!
        self.nameLabel.textColor = fgColor
        self.backgroundColor = bgColor
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        self.parent.dismissAction(sender as AnyObject)
    }
    
}
