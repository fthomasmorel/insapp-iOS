//
//  CASViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/27/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class CASViewController: UIViewController, UIWebViewDelegate{
    
    
    @IBOutlet weak var webView: UIWebView!
    
    var username:String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let url = URL (string: "https://cas.insa-rennes.fr/cas/login?service=https://insapp.insa-rennes.fr/cas/login")
        let req = URLRequest(url: url!)
        
        self.username = nil
        self.webView.loadRequest(req)
        self.webView.delegate = self
    }
 
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if let username = webView.stringByEvaluatingJavaScript(from: "document.getElementById('username').value"), username.characters.count > 0 {
            self.username = username.replacingOccurrences(of: "@insa-rennes.fr", with: "")
        }
        
        if let url = request.url, request.httpMethod == "GET", url.absoluteString.contains("ticket="), let username = self.username, username.characters.count > 0 {
            self.signInUser(username: username)
            return false
        }
        return true
    }
    
    func signInUser(username: String){
        APIManager.signin(username: username, controller: self) { (opt_cred) in
            guard let credentials = opt_cred else { return }
            APIManager.login(credentials, controller: self, completion: { (opt_cred) in
                guard let creds = opt_cred else { return }
                APIManager.fetch(user_id: creds.userId, controller: self, completion: { (opt_user) in
                    guard let _ = opt_user else { return }
                    self.stopLoading()
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "TabViewController") as! UITabBarController
                        vc.delegate = UIApplication.shared.delegate as! UITabBarControllerDelegate?
                        self.present(vc, animated: true, completion: nil)
                    }
                })
            })
        }
    }
    
    @IBAction func showHelpAction(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CreditViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func dismissAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
