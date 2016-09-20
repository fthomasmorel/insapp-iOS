//
//  TutorialPageViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/20/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class TutorialPageViewController: UIViewController{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    var completion:Optional<((String)->())> = nil
    var pageName: String!
    var index:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func completionAction(_ sender: AnyObject) {
        self.completion?(self.pageName)
    }
}
