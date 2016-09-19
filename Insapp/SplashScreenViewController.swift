//
//  SplashScreenViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/13/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class SpashScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let credentials = Credentials.fetch() {
            self.login(credentials)
        }else{
            self.signin()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.lightStatusBar()
    }
    
    func login(_ credentials:Credentials){
        APIManager.login(credentials, completion: { (opt_cred) in
            guard let creds = opt_cred else { self.signin() ; return }
            APIManager.fetch(user_id: creds.userId, controller: self, completion: { (opt_user) in
                guard let _ = opt_user else { self.signin() ; return }
                let application = UIApplication.shared
                let center = UNUserNotificationCenter.current()
                center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in }
                application.registerForRemoteNotifications()
                self.loadViewController(name: "TabViewController")
            })
        })
    }
    
    func signin(){
        DispatchQueue.main.async {
            self.loadViewController(name: "SigninViewController")
        }
    }
    
    func loadViewController(name: String){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: name)
        self.present(vc, animated: true, completion: nil)
    }
}
