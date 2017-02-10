//
//  LoadingCell.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 2/10/17.
//  Copyright © 2017 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

let kLoadingCell = "kLoadingCell"

class LoadingCell: UITableViewCell {
    
    @IBOutlet weak var loaderView: UIActivityIndicatorView!
    
    func load(association: Association){
        self.backgroundColor = UIColor.hexToRGB(association.bgColor!)
        self.loaderView.color = UIColor.hexToRGB(association.fgColor!)
        
    }
    
    func loadUser(){
        self.backgroundColor = .white
        self.loaderView.color = .black
    }
    
}
