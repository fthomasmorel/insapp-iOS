//
//  APIManager+Login.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/13/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

extension APIManager{
    
    static func verifyUser(username: String, password: String, controller: UIViewController, completion:@escaping (Bool) -> ()){
        let params = [
            kLoginUsername: username,
            kLoginPassword: password
        ]
        requestCas(url: "/cas/v1/tickets", method: .post, parameters: params as [String : AnyObject], completion: { result in
            completion(result)
        }) { (errorMessage, statusCode) in completion(false) ; return false }
    }
    
    static func signin(username: String, eraseUser: Bool, controller: UIViewController, completion:@escaping (Optional<Credentials>) -> ()){
        let params = [
            kLoginUsername: username,
            kLoginEraseUser: eraseUser,
            kLoginDeviceId: UIDevice.current.identifierForVendor!.uuidString
        ] as [String : Any]
        request(url: "/signin/user", method: .post, parameters: params as [String : AnyObject], completion: { result in
            guard let json = result as? Dictionary<String, AnyObject> else { completion(.none) ; return }
            completion(Credentials.parseJson(json))
        }) { (errorMessage, statusCode) in return controller.triggerError(errorMessage, statusCode) }
    }
    
    static func login(_ credentials: Credentials, controller:UIViewController, completion:@escaping (Optional<Credentials>, Optional<User>) -> ()){
        let params = [
            kCredentialsUserId: credentials.userId,
            kCredentialsUsername: credentials.username,
            kCredentialsAuthToken: credentials.authToken
        ]
        request(url: "/login/user", method: .post, parameters: params as [String : AnyObject], completion: { result in
            guard let json = result as? Dictionary<String, AnyObject> else { completion(.none, .none) ; return }
            guard let credentialsJson = json["credentials"] as? Dictionary<String, AnyObject> else { completion(.none, .none) ; return }
            guard let credentials = Credentials.parseJson(credentialsJson) else { completion(.none, .none) ; return }
            guard let token = json["sessionToken"] as? Dictionary<String, AnyObject> else { completion(credentials, .none) ; return }
            guard let userJson = json["user"] as? Dictionary<String, AnyObject> else { completion(credentials, .none) ; return }
            guard let user = User.parseJson(userJson) else {
                completion(credentials, .none)
                return
            }
            
            APIManager.token = token["Token"] as! String
            
            completion(credentials, user)
        }) { (errorMessage, statusCode) in return controller.triggerError(errorMessage, statusCode) }
    }
    
}
