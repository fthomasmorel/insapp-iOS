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
    
    @IBOutlet weak var keyboardHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveButton: UIButton!
    var settingViewController:EditUserTableViewController?
    var user:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingViewController = self.childViewControllers.last as? EditUserTableViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.hideNavBar()
        self.notifyGoogleAnalytics()
        self.settingViewController?.avatarImageView.image = user?.avatar()
        self.settingViewController?.usernameTextField.text = "@\(user!.username!)"
        self.settingViewController?.nameTextField.text = user!.name
        self.settingViewController?.emailTextField.text = user!.email
        self.settingViewController?.descriptionTextView.text = user!.desc
        self.settingViewController?.promotionTextField.text = user!.promotion
        self.settingViewController?.genderTextField.text = convertGender[user!.gender!]
        
        NotificationCenter.default.addObserver(self, selector: #selector(EditUserViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        self.lightStatusBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
    }
    
    func keyboardWillShow(_ notification: NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame = (userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue).cgRectValue
        self.keyboardHeightConstraint.constant = keyboardFrame.height
    }
    
    @IBAction func dismissAction(_ sender: AnyObject) {
        self.settingViewController?.view.resignFirstResponder()
        self.settingViewController?.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: AnyObject) {
        if let field = self.checkForm() {
            field.textColor = UIColor.red
        }else{
            self.startLoading()
            APIManager.update(user: self.user!, controller: self, completion: { (opt_user) in
                guard let _ = opt_user else { return }
                self.stopLoading()
                self.dismissAction(self)
            })
        }
    }
    
    func checkForm() -> Optional<UITextField> {
        guard let name = self.settingViewController!.nameTextField.text else { return self.settingViewController!.nameTextField }
        
        let promotion = self.settingViewController!.promotionTextField.text
        let gender = self.settingViewController!.genderTextField.text
        let email = self.settingViewController!.emailTextField.text
        
        user?.name = name.replacingOccurrences(of: "\u{00a0}", with: " ")
        user?.email = email
        user?.promotion = promotion
        user?.gender = convertGender[gender!]
        user?.desc = ""
        
        let characters = NSMutableCharacterSet.alphanumeric()
        characters.addCharacters(in: NSRange(location: 0x1F300, length: 0x1F700 - 0x1F300))
        if var description = self.settingViewController?.descriptionTextView.text, let _ = description.rangeOfCharacter(from: characters as CharacterSet) {
            description.condenseNewLine()
            user?.desc = description
        }
        
        return nil
    }
}

