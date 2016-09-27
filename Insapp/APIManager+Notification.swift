//
//  APIManager+Notification.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/19/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit


let kNotificationUserId = "userid"
let kNotificationToken = "token"
let kNotificationOs = "os"

extension APIManager {
    
    static func updateNotification(token: String, credentials: Credentials){
        let params = [
            kNotificationUserId: credentials.userId,
            kNotificationToken: token,
            kNotificationOs: "iOS",
        ]
        requestWithToken(url: "/notification", method: .post, parameters: params as [String : AnyObject], completion: { result in
            
        }) { (errorMessage, statusCode) in
            
            return false }
    }
}

