//
//  UserCell.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/30/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class UserCell: UITableViewCell{
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var user:User!
    
    func load(user: User){
        self.user = user
        self.avatarImageView.image = self.user.avatar()
        self.avatarImageView.layer.cornerRadius = 20
        self.avatarImageView.layer.masksToBounds = true
        self.avatarImageView.backgroundColor = kWhiteColor
        self.avatarImageView.layer.borderColor = kDarkGreyColor.cgColor
        self.avatarImageView.layer.borderWidth = 1
        
        self.usernameLabel.text = "@\(user.username!)"
        self.nameLabel.text = ""
        if let name = user.name {
            self.nameLabel.text = name
        }
    }
    
}
