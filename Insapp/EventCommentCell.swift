//
//  EventCommentCell.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 2/7/17.
//  Copyright © 2017 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

let kEventCommentCell = "kEventCommentCell"

class EventCommentCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func layoutSubviews() {
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2
        self.avatarImageView.layer.masksToBounds = true
        self.avatarImageView.backgroundColor = kWhiteColor
        self.avatarImageView.layer.borderColor = kDarkGreyColor.cgColor
        self.avatarImageView.layer.borderWidth = 1
    }
}
