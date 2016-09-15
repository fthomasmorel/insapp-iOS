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
    "3EII", "3GM", "3GCU", "3GMA", "3INFO", "3SGM", "3SRC",
    "4EII", "4GM", "4GCU", "4GMA", "4INFO", "4SGM", "4SRC",
    "5EII", "5GM", "5GCU", "5GMA", "5INFO", "5SGM", "5SRC",
    "1STPI", "2STPI"
]

class EditUserTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var promotionTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailPublicSwitch: UISwitch!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        promotionTextField.inputView = pickerView
        
        nameTextField.becomeFirstResponder()
        
        emailPublicSwitch.addTarget((self.parent as! EditUserViewController), action: Selector(("updateSaveButton")), for: .allEvents)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return promotions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return promotions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        promotionTextField.text = promotions[row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 7 {
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
    
    
}

