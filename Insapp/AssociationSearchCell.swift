//
//  AssociationSearchCell.swift
//  Insapp
//
//  Created by Guillaume Courtet on 29/11/2016.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import UIKit

class AssociationSearchCell: UICollectionViewCell {
    
    @IBOutlet weak var associationImageView: UIImageView!
    @IBOutlet weak var associationNameLabel: UILabel!
    var more = 0
    
    override func layoutSubviews() {
        if(more == 1) {
        super.layoutSubviews()
        self.associationImageView.frame = CGRect(x: 8, y: 0, width: self.frame.width-16, height: self.frame.width-16)            
        self.associationImageView.layer.cornerRadius = self.associationImageView.frame.width/2            
        self.associationImageView.layer.masksToBounds = true
        self.associationImageView.backgroundColor = kWhiteColor
        self.associationImageView.layer.borderColor = kLightGreyColor.cgColor
        self.associationImageView.layer.borderWidth = 1
        self.associationNameLabel.frame = CGRect(x: 0, y: self.frame.height-15, width: self.frame.width, height: 15)
        }
    }
    
    func load(association : Association){
        let photo_url = kCDNHostname + association.profilePhotoURL!
        self.associationImageView.downloadedFrom(link: photo_url)
        self.associationNameLabel.text = "@\(association.name!.lowercased())"
    }
    
}
