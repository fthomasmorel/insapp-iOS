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
let kWhiteColor = UIColor.white

let kNormalFont = "KohinoorBangla-Regular"
let kBoldFont = "KohinoorBangla-Semibold"
let kLightFont = "KohinoorBangla-Light"
class UserViewController: UIViewController {
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var promotionLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var editButton: UIButton!
    
    var user:User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.fetchUser(user_id: Credentials.fetch()!.userId)
        
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.size.width/2
        profilePictureImageView.layer.masksToBounds = true
        profilePictureImageView.backgroundColor = kLightGreyColor
        
        if self.user == nil {
            usernameLabel.backgroundColor = kLightGreyColor
            nameLabel.backgroundColor = kLightGreyColor
            promotionLabel.backgroundColor = kLightGreyColor
            descriptionTextView.backgroundColor = kLightGreyColor
        }
    }
    
    func fetchUser(user_id:String){
        APIManager.fetch(user_id: user_id) { (opt_user) in
            guard let user = opt_user else { self.triggerError("Error Fetching User") ; return }
            self.user = user
            self.initView()
        }
    }
    
    func setEditable(_ editable:Bool){
        self.editButton.isHidden = !editable
    }
    
    func initView(){
        
        usernameLabel.backgroundColor = kWhiteColor
        nameLabel.backgroundColor = kWhiteColor
        promotionLabel.backgroundColor = kWhiteColor
        descriptionTextView.backgroundColor = kWhiteColor
        
        //self.profilePictureImageView.image = imageForPromotion(user.promotion!)
        self.usernameLabel.text = "@\(user.username!)"
        self.nameLabel.text = user.name!
        self.promotionLabel.text = user.promotion
        self.descriptionTextView.text = user.desc!
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
    
}
