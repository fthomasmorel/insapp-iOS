//
//  AssociationViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/13/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class AssociationViewController: UIViewController
{
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var backButton: UIButton!
    
    var eventListViewController: EventListViewController!
    var association: Association!
    var events:[Event]!
    var fontColor: UIColor!
    var viewNeverLoaded = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eventListViewController = self.childViewControllers.last as? EventListViewController
        self.generateViewForAssociation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.notifyGoogleAnalytics()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.descriptionTextView.scrollRangeToVisible(NSRange(location:0, length:0))
    }
    
    func generateViewForAssociation(){
        self.coverImageView.downloadedFrom(link: kCDNHostname + self.association.coverPhotoURL!, contentMode: .scaleAspectFill, completion: { self.computeGradient() })
        self.view.backgroundColor = UIColor.hexToRGB(association.bgColor!)
        self.fontColor = UIColor.hexToRGB(association.fgColor!)
        self.nameLabel.text = "@\(association.name!.lowercased())"
        self.nameLabel.textColor = self.fontColor
        self.descriptionTextView.text = association.desc
        self.descriptionTextView.textColor = self.fontColor
        self.computeHeightForDescription()
        
        let arrow = (association.fgColor == "ffffff" ? UIImage(named: "arrow_left_white")! : UIImage(named: "arrow_left_black")!)
        self.backButton.setImage(arrow, for: .normal)
        self.changeStatusBarForColor(colorStr: association.fgColor)
        
        self.initEventView()
    }
    
    func computeHeightForDescription(){
        let frame = self.descriptionTextView.frame
        let height = self.descriptionTextView.contentSize.height
        self.descriptionTextView.isScrollEnabled = false
        self.descriptionTextView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: height)
    }
    
    func computeGradient(){
        let opaqueColor = UIColor.hexToRGB(association.bgColor!)
        let transColor = opaqueColor.withAlphaComponent(0)
        
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [opaqueColor.cgColor, transColor.cgColor]
        gradient.locations = [0 , 1]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 0.1)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.coverImageView.frame.size.width, height: 180)
        
        if let sublayers = self.coverImageView.layer.sublayers {
            for sublayer in sublayers {
                sublayer.removeFromSuperlayer()
            }
        }
        self.coverImageView.layer.insertSublayer(gradient, at: 0)
    }
    
    @IBAction func dismissAction(_ sender: AnyObject) {
        self.navigationController!.popViewController(animated: true)
    }
    
    func initEventView(){
        self.eventListViewController.fontColor = self.fontColor
        self.eventListViewController.eventIds = self.association.events!
        self.eventListViewController.fetchEvents()
    }
}
