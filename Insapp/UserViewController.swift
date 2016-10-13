//
//  MeViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/13/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit


class UserViewController: UIViewController, EventListDelegate {
    
    @IBOutlet weak var optionButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var eventView: UIView!
    @IBOutlet weak var eventViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var promotionLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var creditButton: UIButton!
    
    var eventListViewController: EventListViewController!
    var isEditable:Bool = true
    var canReturn:Bool = false
    var user_id:String!
    var user:User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eventListViewController = self.childViewControllers.last as? EventListViewController
        if self.user_id == nil {
            self.user_id = Credentials.fetch()!.userId
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.notifyGoogleAnalytics()
        self.editButton.isHidden = !self.isEditable
        self.optionButton.isHidden = self.isEditable
        self.backButton.isHidden = !self.canReturn
        self.creditButton.isHidden = self.canReturn
        
        DispatchQueue.main.async {
            self.hideNavBar()
            
            self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.size.width/2
            self.profilePictureImageView.layer.masksToBounds = true
            self.profilePictureImageView.backgroundColor = kWhiteColor
            self.profilePictureImageView.layer.borderColor = kDarkGreyColor.cgColor
            self.profilePictureImageView.layer.borderWidth = 1
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(UserViewController.editAction(_:)))
            self.profilePictureImageView.isUserInteractionEnabled = true
            self.profilePictureImageView.addGestureRecognizer(tap)
        }
        
        if self.user == nil {
            usernameLabel.backgroundColor = kLightGreyColor
            nameLabel.backgroundColor = kLightGreyColor
            promotionLabel.backgroundColor = kLightGreyColor
            emailLabel.backgroundColor = kLightGreyColor
            descriptionTextView.backgroundColor = kLightGreyColor
        }
        
        self.fetchUser(user_id: user_id)
        self.lightStatusBar()
    }
    
    func fetchUser(user_id:String){
        APIManager.fetch(user_id: user_id, controller: self) { (opt_user) in
            guard let user = opt_user else { return }
            self.user = user
            self.initView()
            self.initEventView()
        }
    }
    
    func setEditable(_ editable:Bool){
        self.isEditable = editable
    }
    
    func canReturn(_ canReturn: Bool){
        self.canReturn = canReturn
    }
    
    func initView(){
        
        usernameLabel.backgroundColor = kClearColor
        nameLabel.backgroundColor = kClearColor
        promotionLabel.backgroundColor = kClearColor
        emailLabel.backgroundColor = kClearColor
        descriptionTextView.backgroundColor = kClearColor
        
        self.profilePictureImageView.image = user.avatar()
        self.usernameLabel.text = "@\(user.username!)"
        self.nameLabel.text = user.name!
        self.emailLabel.text = user.email
        self.promotionLabel.text = user.promotion
        self.descriptionTextView.text = user.desc!
        self.descriptionTextView.linkTextAttributes = [NSForegroundColorAttributeName: UIColor.black, NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
    }
    
    func initEventView(){
        self.eventListViewController.eventIds = self.user.events!
        self.eventListViewController.delegate = self
        self.eventListViewController.fetchEvents()
    }
    
    func imageForPromotion(_ promotion: String) -> UIImage {
        var promo = promotion
        promo.remove(at: promo.startIndex)
        return UIImage(named: promo)!
    }
    
    func updateHeightForEventListView(eventNumber: Int){
        DispatchQueue.main.async {
            switch eventNumber {
            case 0:
                self.eventViewHeightConstraint.constant = 0
                self.eventListViewController.view.isHidden = true
                self.eventListViewController.eventTableView.isScrollEnabled = false
                break
            default:
                self.eventListViewController.view.isHidden = false
                self.eventViewHeightConstraint.constant = CGFloat(eventNumber*60) + CGFloat(30 + 10)
                self.eventListViewController.eventTableView.isScrollEnabled = false
            }
            self.updateViewConstraints()
        }
    }
    
    @IBAction func editAction(_ sender: AnyObject) {
        if !self.isEditable { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EditUserViewController") as! EditUserViewController
        vc.user = self.user
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func optionAction(_ sender: AnyObject) {
        let alertController = Alert.create(alert: .reportUser) { report in
            if report {
                APIManager.report(user: self.user, controller: self)
                let alert = Alert.create(alert: .reportConfirmation)
                self.present(alert, animated: true, completion: nil)
            }
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func creditAction(_ sender: AnyObject) {
        if self.canReturn { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CreditViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func dismissAction(_ sender: AnyObject) {
        self.navigationController!.popViewController(animated: true)
    }
}
