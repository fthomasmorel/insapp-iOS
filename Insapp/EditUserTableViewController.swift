//
//  EditUserTableViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/13/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications


class EditUserTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var promotionTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionLengthLabel: UILabel!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var avatarHelpLabel: UILabel!
    @IBOutlet weak var insappImageView: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var addToCalendarSwitch: UISwitch!
    
    
    var promotionPickerView:UIPickerView!
    var genderPickerView:UIPickerView!
    var isNotificationEnabled:Bool = false
    
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
            self.avatarImageView.layer.borderColor = kDarkGreyColor.cgColor
            self.avatarImageView.layer.masksToBounds = true
            self.avatarImageView.layer.borderWidth = 1
            
            self.avatarImageView.backgroundColor = kWhiteColor
            
            let tap = UITapGestureRecognizer(target: self.promotionTextField, action: #selector(UIResponder.becomeFirstResponder))
            self.avatarImageView.addGestureRecognizer(tap)
            self.avatarImageView.isUserInteractionEnabled = true
            
            self.updateDescriptionLengthLabel(length: self.descriptionTextView.text.characters.count)
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            
            self.nameTextField.delegate = self
            
            self.descriptionTextView.isScrollEnabled = false
            self.descriptionTextView.isScrollEnabled = true
            
            self.insappImageView.layer.masksToBounds = true
            self.insappImageView.layer.cornerRadius = 10
            self.versionLabel.text = ""
            if let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
                self.versionLabel.text = "Insapp v\(version)"
            }
            
            self.addToCalendarSwitch.isOn = false
            if let addToCalendar = UserDefaults.standard.object(forKey: kSuggestCalendar) as? Bool {
                self.addToCalendarSwitch.isOn = addToCalendar
            }
        }
        
        self.lightStatusBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.promotionPickerView.selectRow(promotions.index(of: self.promotionTextField.text!)!, inComponent: 0, animated: false)
        self.genderPickerView.selectRow(genders.index(of: self.genderTextField.text!)!, inComponent: 0, animated: false)
        
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            self.isNotificationEnabled = settings.authorizationStatus == .authorized
            DispatchQueue.main.async {
                self.notificationSwitch.isOn = self.isNotificationEnabled
            }
        }
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
        self.avatarHelpLabel.isHidden = self.avatarImageView.image != #imageLiteral(resourceName: "avatar-default")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 9 {
            let alert = Alert.create(alert: .deleteUser, completion: { (success) in
                if success {
                    self.deleteUser()
                }
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func deleteUser(){
        APIManager.delete(user: (self.parent as! EditUserViewController).user!, controller: self.parent!, completion: { (result) in
            if result == .success {
                Credentials.delete()
                UserDefaults.standard.removeObject(forKey: kSuggestCalendar)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "SpashScreenViewController")
                self.present(vc, animated: true, completion: nil)
            }
        })
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == textField.text?.characters.count, string == " ", let text = textField.text {
            textField.text = text + "\u{00a0}"
            return false
        }
        return true
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
    
    @IBAction func notificationStatusAction(_ sender: AnyObject) {
        if self.notificationSwitch.isOn {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                if !granted {
                    let alert = Alert.create(alert: .notificationEnable)
                    self.present(alert, animated: true, completion: nil)
                    DispatchQueue.main.async {
                        self.notificationSwitch.isOn = self.isNotificationEnabled
                    }
                }else{
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }else{
            let alert = Alert.create(alert: .notificationDisable)
            self.present(alert, animated: true, completion: nil)
            self.notificationSwitch.isOn = self.isNotificationEnabled
        }
    }
    
    
    @IBAction func addToCalendarSwitchAction(_ sender: AnyObject) {
        UserDefaults.standard.set(self.addToCalendarSwitch.isOn, forKey: kSuggestCalendar)
    }
    
}

