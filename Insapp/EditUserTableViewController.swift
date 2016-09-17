//
//  EditUserTableViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/13/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

let promotions = [
    "",
    "3EII", "3GM", "3GCU", "3GMA", "3INFO", "3SGM", "3SRC",
    "4EII", "4GM", "4GCU", "4GMA", "4INFO", "4SGM", "4SRC",
    "5EII", "5GM", "5GCU", "5GMA", "5INFO", "5SGM", "5SRC",
    "1STPI", "2STPI"
]

let genders = [
    "-", "Féminin", "Masculin"
]

let convertGender = [
    ""          : "-",
    "female"    : "Féminin",
    "male"      : "Masculin",
    "-"         : "",
    "Féminin"   : "female",
    "Masculin"  : "male"
]

class EditUserTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var promotionTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var promotionPickerView:UIPickerView!
    var genderPickerView:UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.promotionPickerView = UIPickerView()
        self.promotionPickerView.dataSource = self
        self.promotionPickerView.delegate = self
        self.promotionTextField.inputView = self.promotionPickerView
        
        self.genderPickerView = UIPickerView()
        self.genderPickerView.dataSource = self
        self.genderPickerView.delegate = self
        self.genderTextField.inputView = self.genderPickerView
        
        DispatchQueue.main.async {
            self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2
            self.avatarImageView.layer.masksToBounds = true
            self.avatarImageView.backgroundColor = kWhiteColor
            self.avatarImageView.layer.borderColor = kDarkGreyColor.cgColor
            self.avatarImageView.layer.borderWidth = 1
            
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.promotionPickerView.selectRow(promotions.index(of: self.promotionTextField.text!)!, inComponent: 0, animated: false)
        self.genderPickerView.selectRow(genders.index(of: self.genderTextField.text!)!, inComponent: 0, animated: false)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case self.genderPickerView:
            return genders.count
        default:
            return promotions.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case self.genderPickerView:
            return genders[row]
        default:
            return promotions[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case self.genderPickerView:
            self.genderTextField.text = genders[row]
        default:
            self.promotionTextField.text = promotions[row]
        }
        self.updateAvatar()
    }
    
    func updateAvatar(){
        let gender = self.genderTextField.text!
        let promotion = self.promotionTextField.text!
        self.avatarImageView.image = User.avatarFor(gender: convertGender[gender]!, andPromotion: promotion)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 7 {
            let alert = UIAlertController(title: "Attention", message: "Veux tu vraiment supprimer ton compte Insapp ?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Non", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            alert.addAction(UIAlertAction(title: "Oui", style: .destructive, handler: { action in
                switch action.style{
                case .default:
                    break
                case .cancel:
                    break
                case .destructive:
                    self.deleteUser()
                    break
                }
            }))
        }
    }
    
    func deleteUser(){
        APIManager.delete(user: (self.parent as! EditUserViewController).user!, completion: { (result) in
            if result == .success {
                Credentials.delete()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "SigninViewController")
                self.present(vc, animated: true, completion: nil)
            }else{
                self.triggerError("Error When Deleting User")
            }
        })
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            textField.text = text + string
            if string == "" {
                textField.text = text.substring(to: text.index(before: text.endIndex))
            }
        }else{
            textField.text = string
        }
        (self.parent as! EditUserViewController).updateSaveButton()
        return false
    }
    
    @IBAction func handleTap(_ sender: AnyObject) {
        self.descriptionTextView.becomeFirstResponder()
    }
    
}

