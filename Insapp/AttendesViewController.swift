//
//  AttendesViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 10/2/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class AttendesViewController: UIViewController, ListUserDelegate {
    
    var userIds:[String] = []
    var listUserViewController: ListUserViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listUserViewController = self.childViewControllers.last as? ListUserViewController
        self.listUserViewController?.userIds = userIds
        self.listUserViewController?.fetchUsers()
        self.listUserViewController?.delegate = self
    }
    
    func didTouchUser(_ user:User){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "UserViewController") as! UserViewController
        vc.user_id = user.id
        vc.setEditable(false)
        vc.canReturn(true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func dismissAction(_ sender: AnyObject) {
        self.navigationController!.popViewController(animated: true)
    }
    
}
