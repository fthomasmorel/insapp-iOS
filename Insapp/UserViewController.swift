//
//  MeViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/13/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

let kLightGreyColor = UIColor(colorLiteralRed: 238/255, green: 238/255, blue: 238/255, alpha: 1)
let kDarkGreyColor = UIColor(colorLiteralRed: 180/255, green: 180/255, blue: 180/255, alpha: 1)
let kRedColor = UIColor(colorLiteralRed: 232/255, green: 92/255, blue: 86/255, alpha: 1)
let kWhiteColor = UIColor.white
let kClearColor = UIColor.clear

let kNormalFont = "KohinoorBangla-Regular"
let kBoldFont = "KohinoorBangla-Semibold"
let kLightFont = "KohinoorBangla-Light"
class UserViewController: UIViewController {
    
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
        self.fetchUser(user_id: user_id)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.editButton.isHidden = !self.isEditable
        self.backButton.isHidden = !self.canReturn
        
        DispatchQueue.main.async {
            self.profilePictureImageView.layer.cornerRadius = self.profilePictureImageView.frame.size.width/2
            self.profilePictureImageView.layer.masksToBounds = true
            self.profilePictureImageView.backgroundColor = kWhiteColor
            self.profilePictureImageView.layer.borderColor = kDarkGreyColor.cgColor
            self.profilePictureImageView.layer.borderWidth = 1
        }
        
        if self.user == nil {
            usernameLabel.backgroundColor = kLightGreyColor
            nameLabel.backgroundColor = kLightGreyColor
            promotionLabel.backgroundColor = kLightGreyColor
            emailLabel.backgroundColor = kLightGreyColor
            descriptionTextView.backgroundColor = kLightGreyColor
        }
        
        self.lightStatusBar()
    }
    
    func fetchUser(user_id:String){
        let user = User.fetch()!
        if user.id == user_id {
            self.user = user
            self.initView()
            self.initEventView()
            return
        }
        APIManager.fetch(user_id: user_id) { (opt_user) in
            guard let user = opt_user else { self.triggerError("Error Fetching User") ; return }
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
    }
    
    func initEventView(){
        self.eventListViewController.eventIds = self.user.events!
        self.eventListViewController.fetchEvents()
        
        switch self.user.events!.count {
        case 0:
            self.eventViewHeightConstraint.constant = 0
            break
        case let nbEvent where nbEvent < 3:
            self.eventViewHeightConstraint.constant = CGFloat(nbEvent*60) + CGFloat(30 + 10)
            break
        default:
            self.eventViewHeightConstraint.constant = 180
            break
        }
        self.updateViewConstraints()
    }
    
    func imageForPromotion(_ promotion: String) -> UIImage {
        var promo = promotion
        promo.remove(at: promo.startIndex)
        return UIImage(named: promo)!
    }
    
    @IBAction func editAction(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EditUserViewController") as! EditUserViewController
        vc.user = self.user
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func dismissAction(_ sender: AnyObject) {
        self.navigationController!.popViewController(animated: true)
    }
}
