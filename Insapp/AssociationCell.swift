//
//  AssociationCell.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/17/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class AssociationCell: UICollectionViewCell {
    
    @IBOutlet weak var associationImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func layoutSubviews() {
        self.associationImageView.layer.cornerRadius = self.associationImageView.frame.width/2
        self.associationImageView.layer.borderColor = kLightGreyColor.cgColor
        self.associationImageView.layer.borderWidth = 1
        self.layer.borderWidth = 1
        self.layer.borderColor = kLightGreyColor.cgColor
    }
    
    func load(association: Association){
        let photo_url = kCDNHostname + association.profilePhotoURL!
        self.associationImageView.downloadedFrom(link: photo_url)
        self.nameLabel.text = association.name
    }
    
}
