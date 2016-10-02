//
//  AssociationViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/13/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class AssociationViewController: UIViewController, EventListDelegate {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var eventListHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailButton: UIButton!
    
    
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
        self.descriptionTextView.textColor = self.fontColor
        self.descriptionTextView.linkTextAttributes = [NSForegroundColorAttributeName: self.fontColor, NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        
        let arrow = (association.fgColor == "ffffff" ? UIImage(named: "arrow_left_white")! : UIImage(named: "arrow_left_black")!)
        self.backButton.setImage(arrow, for: .normal)
        self.changeStatusBarForColor(colorStr: association.fgColor)
        
        let letter = (self.association.fgColor! == "ffffff" ? UIImage(named: "letter_white")! : UIImage(named: "letter_black")!)
        self.emailButton.setImage(letter, for: .normal)
        
        self.initEventView()
        
        self.descriptionTextView.text = self.association.desc
        self.descriptionTextView.isScrollEnabled = false
        self.descriptionTextView.isScrollEnabled = true
        self.descriptionTextView.scrollRangeToVisible(NSRange(location:0, length:0))
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
    
    func updateHeightForEventListView(eventNumber: Int){
        DispatchQueue.main.async {
            switch eventNumber {
            case 0:
                self.eventListHeightConstraint.constant = 0
                self.eventListViewController.view.isHidden = true
                self.eventListViewController.eventTableView.isScrollEnabled = false
                break
            default:
                self.eventListViewController.view.isHidden = false
                self.eventListHeightConstraint.constant = CGFloat(eventNumber*60) + CGFloat(30 + 10)
                self.eventListViewController.eventTableView.isScrollEnabled = false
                break
            }
            self.updateViewConstraints()
        }
    }

    @IBAction func openEmailAction(_ sender: AnyObject) {
        let email = self.association.email!
        let url = URL(string: "mailto:\(email)")
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    
    @IBAction func dismissAction(_ sender: AnyObject) {
        self.navigationController!.popViewController(animated: true)
    }
    
    func initEventView(){
        self.eventListViewController.fontColor = self.fontColor
        self.eventListViewController.eventIds = self.association.events!
        self.eventListViewController.delegate = self
        self.eventListViewController.fetchEvents()
    }
}
