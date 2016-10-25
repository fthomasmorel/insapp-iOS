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
    
    var hasSentPost = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let url = URL (string: "https://cas.insa-rennes.fr/cas/login?service=https%3A%2F%2Finsapp.fr%2F&renew=false")
        let req = URLRequest(url: url!)
    
        let cookieJar = HTTPCookieStorage.shared
        for cookie in cookieJar.cookies! {
            cookieJar.deleteCookie(cookie)
        }
        self.webView.loadRequest(req)
        self.webView.delegate = self
    }
 
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if request.httpMethod == "POST" && !hasSentPost {
            let alert = Alert.create(alert: .switchPhone) { (success) in
                if success {
                    self.hasSentPost = true
                    self.webView.loadRequest(request)
                }else{
                    self.hasSentPost = false
                    self.dismissAction(self)
                }
            }
            self.present(alert, animated: true, completion: nil)
            return false
        }
        
        if let url = request.url, request.httpMethod == "GET", url.absoluteString.contains("ticket=") {
            let ticket = url.absoluteString.components(separatedBy: "ticket=").last!
            self.signInUser(ticket: ticket)
            return false
        }
        return true
    }
    
    func signInUser(ticket: String){
        APIManager.signin(ticket: ticket, controller: self) { (opt_cred) in
            guard let credentials = opt_cred else { return }
            APIManager.login(credentials, controller: self, completion: { (opt_cred, opt_user) in
                guard let _ = opt_cred else {
                    self.displayError(message: kErrorServer)
                    return
                }
                guard let _ = opt_user else {
                    self.displayError(message: kErrorUnkown)
                    return
                }
                self.stopLoading()
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "TabViewController") as! UITabBarController
                    vc.delegate = UIApplication.shared.delegate as! UITabBarControllerDelegate?
                    self.present(vc, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func showHelpAction(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CreditViewController")
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func dismissAction(_ sender: AnyObject) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
