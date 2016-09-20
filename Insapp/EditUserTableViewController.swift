//
//  EditUserTableViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/13/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit


class EditUserTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var promotionTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionLengthLabel: UILabel!
    
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
     
            
            self.updateDescriptionLengthLabel(length: self.descriptionTextView.text.characters.count)
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
        
        self.lightStatusBar()
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
        APIManager.delete(user: (self.parent as! EditUserViewController).user!, controller: self.parent!, completion: { (result) in
            if result == .success {
                Credentials.delete()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "SpashScreenViewController")
                self.present(vc, animated: true, completion: nil)
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let content = textView.text else { return true }
        
        let newLength = content.characters.count + text.characters.count - range.length
        
        if (newLength <= kMaxDescriptionLength){
            self.updateDescriptionLengthLabel(length: newLength)
        }
        
        return newLength <= kMaxDescriptionLength
    }
    
    func updateDescriptionLengthLabel(length: Int){
        self.descriptionLengthLabel.text = "\(kMaxDescriptionLength - length)"
    }
    
    @IBAction func handleTap(_ sender: AnyObject) {
        self.descriptionTextView.becomeFirstResponder()
    }
    
}

