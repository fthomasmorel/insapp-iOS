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
    @IBOutlet weak var button: UIButton!
    
    var completion:Optional<((String)->())> = nil
    var pageName: String!
    var index:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard button != nil else { return }
  
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.duration = 0.08
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSNumber(value: -5 * Float.pi / 180 )
        animation.toValue = NSNumber(value: 5 * Float.pi / 180 )
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        button.layer.add(animation, forKey: "position")
        UIView.animate(withDuration: 0.5, animations: { 
            self.button.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }) { (finished) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.button.transform = CGAffineTransform(scaleX: 1, y: 1)
                })
        }
    }

    @IBAction func completionAction(_ sender: AnyObject) {
        self.completion?(self.pageName)
    }
}
