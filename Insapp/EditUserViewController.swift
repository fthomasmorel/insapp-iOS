//
//  EditUserViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/13/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class EditUserViewController: UIViewController {
    
    @IBOutlet weak var saveButton: UIButton!
    var settingViewController:EditUserTableViewController?
    var user:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingViewController = self.childViewControllers.last as? EditUserTableViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.settingViewController?.usernameTextField.text = "@\(user!.username!)"
        self.settingViewController?.nameTextField.text = user!.name
        self.settingViewController?.emailTextField.text = user!.email
        self.settingViewController?.descriptionTextView.text = user!.desc
        self.settingViewController?.promotionTextField.text = user!.promotion
        self.settingViewController?.emailPublicSwitch.setOn(user!.isEmailPublic, animated: false)
        
        self.disableSabeButton()
    }
    
    @IBAction func dismissAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: AnyObject) {
        if let field = self.checkForm() {
            field.textColor = UIColor.red
        }else{
            APIManager.update(user: self.user!, completion: { (opt_user) in
                guard let _ = opt_user else { self.triggerError("Error Updating User") ; return }
                self.dismissAction(self)
            })
        }
    }
    
    func checkForm() -> Optional<UITextField> {
        guard let name = self.settingViewController!.nameTextField.text else { return self.settingViewController!.nameTextField }
        guard let email = self.settingViewController!.emailTextField.text else { return self.settingViewController!.emailTextField }
        
        if !email.hasSuffix("@insa-rennes.fr") { return self.settingViewController!.emailTextField }
        
        let isPublic = self.settingViewController!.emailPublicSwitch.isOn
        let promotion = self.settingViewController!.promotionTextField.text
        
        user?.name = name
        user?.email = email
        user?.isEmailPublic = isPublic
        user?.promotion = promotion
        
        if let description = self.settingViewController?.descriptionTextView.text {
            user?.desc = description
        }
        
        return nil
    }
    
    func updateSaveButton(){
        guard let name = self.settingViewController!.nameTextField.text else { self.disableSabeButton() ; return }
        guard let email = self.settingViewController!.emailTextField.text else { self.disableSabeButton() ; return }
        guard let promo = self.settingViewController!.promotionTextField.text else { self.disableSabeButton() ; return }
        
        if !email.hasSuffix("@insa-rennes.fr") { self.disableSabeButton() ; return }
        if (name.characters.count < 1) { self.disableSabeButton() ; return }
        if (promo.characters.count < 1) { self.disableSabeButton() ; return }
        
        self.saveButton.setTitleColor(kWhiteColor, for: .normal)
        self.saveButton.isEnabled = true
    }
    
    func disableSabeButton(){
        self.saveButton.setTitleColor(kDarkGreyColor, for: .normal)
        self.saveButton.isEnabled = false
    }
}

