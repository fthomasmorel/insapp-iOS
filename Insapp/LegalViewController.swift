//
//  LegalViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 10/13/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit


class LegalViewController: UIViewController{
    
    @IBOutlet weak var webView: UIWebView!
    
    var onAgree:Optional<() -> ()> = nil
    
    override func viewWillAppear(_ animated: Bool) {
        let url = URL (string: kAPIHostname + "/legal")
        let req = URLRequest(url: url!)
        self.webView.loadRequest(req)
    }
    
    @IBAction func agreeAction(_ sender: AnyObject) {
        self.dismiss(animated: true) {
            self.onAgree?()
        }
    }
    
    @IBAction func backAction(_ sender: AnyObject) {
        self.dismiss(animated: true)
    }
}
