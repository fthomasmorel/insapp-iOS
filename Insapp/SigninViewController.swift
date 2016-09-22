//
//  LoginViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/12/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class SigninViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var validateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.usernameTextField.becomeFirstResponder()
        self.checkForm()
        self.lightStatusBar()
        self.notifyGoogleAnalytics()
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
        self.checkForm()
        return false
    }
    
    func checkForm(){
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            self.validateButton.isEnabled = false
            return
        }
        if username.characters.count == 0 || password.characters.count == 0 {
            self.validateButton.isEnabled = false
            return
        }
        self.validateButton.isEnabled = true
    }
    
    @IBAction func connectAction(_ sender: AnyObject) {
        guard let username = usernameTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        self.usernameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.startLoading()
        APIManager.signin(username: username, password: password, controller: self) { (opt_cred) in
            guard let credentials = opt_cred else { return }
            APIManager.login(credentials, controller: self, completion: { (opt_cred) in
                guard let creds = opt_cred else { return }
                APIManager.fetch(user_id: creds.userId, controller: self, completion: { (opt_user) in
                    guard let _ = opt_user else { return }
                    self.stopLoading()
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "TabViewController")
                        self.present(vc, animated: true, completion: nil)
                    }
                })
            })
        }
    }
    
    @IBAction func creditAction(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CreditViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func dismissAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

