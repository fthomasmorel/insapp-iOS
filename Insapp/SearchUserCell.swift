//
//  SearchUserCell.swift
//  Insapp
//
//  Created by Guillaume Courtet on 27/11/2016.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//


import Foundation
import UIKit

class SearchUserCell: UITableViewCell{
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func loadUser(user: User){
        self.avatarImageView.image = user.avatar()
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
