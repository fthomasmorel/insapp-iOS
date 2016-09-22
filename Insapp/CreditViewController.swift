//
//  CreditViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/22/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class CreditViewController: UIViewController{
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL (string: kAPIHostname + "/credit");
        let req = URLRequest(url: url!);
        webView.loadRequest(req);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.notifyGoogleAnalytics()
        self.lightStatusBar()
    }
    
    @IBAction func dismissAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
