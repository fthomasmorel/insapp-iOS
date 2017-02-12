//
//  UserBarCodeCell.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 2/10/17.
//  Copyright © 2017 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit


let kUserBarCodeCell = "kUserBarCodeCell"

class UserBarCodeCell: UITableViewCell {
    
    @IBOutlet weak var barCodeImageView: UIImageView!
    @IBOutlet weak var barCodeLabel: UILabel!
    
    func load(){
        if let barcode = UserDefaults.standard.object(forKey: kBarCodeAmicalistCard) as? String, barcode.characters.count >= 9 {
            self.barCodeLabel.text = barcode
            self.barCodeImageView.load(barcode: barcode)
        }
    }
 
    static func getHeightForUser(user: User?) -> CGFloat {
        if user == nil { return 0 }
        if user?.id != User.userInstance?.id { return 0 }
        if let barcode = UserDefaults.standard.object(forKey: kBarCodeAmicalistCard) as? String, barcode.characters.count >= 9  {
            return 160
        }
        return 0
    }
    
}
