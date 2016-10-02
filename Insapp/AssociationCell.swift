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
        super.layoutSubviews()
        self.associationImageView.frame = CGRect(x: 8, y: 0, width: self.frame.width-16, height: self.frame.width-16)
        self.associationImageView.layer.cornerRadius = self.associationImageView.frame.width/2
        self.associationImageView.layer.borderColor = kLightGreyColor.cgColor
        self.associationImageView.layer.borderWidth = 1
        self.nameLabel.frame = CGRect(x: 0, y: self.frame.height-15, width: self.frame.width, height: 15)
    }
    
    func load(association: Association){
        let photo_url = kCDNHostname + association.profilePhotoURL!
        self.associationImageView.downloadedFrom(link: photo_url)
        self.nameLabel.text = "@\(association.name!.lowercased())"
    }
    
}
