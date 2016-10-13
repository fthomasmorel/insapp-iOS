//
//  APIManager+User.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/13/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

enum Result {
    case success
    case failure
}

extension APIManager{
    
    static func fetch(user_id: String, controller: UIViewController, completion:@escaping (_ user:Optional<User>) -> ()){
        requestWithToken(url: "/user/\(user_id)", method: .get, completion: { (result) in
            guard let json = result as? Dictionary<String, AnyObject> else { completion(.none) ; return }
            completion(User.parseJson(json))
        }) { (errorMessage, statusCode) in return controller.triggerError(errorMessage, statusCode) }
    }
    
    static func update(user: User, controller: UIViewController, completion:@escaping (_ user:Optional<User>) -> ()){
        let params = User.toJson(user)
        requestWithToken(url: "/user/\(user.id!)", method: .put, parameters: params, completion: { (result) in
            guard let json = result as? Dictionary<String, AnyObject> else { completion(.none) ; return }
            completion(User.parseJson(json))
        }) { (errorMessage, statusCode) in return controller.triggerError(errorMessage, statusCode) }
    }
    
    static func delete(user: User, controller: UIViewController, completion:@escaping (_ user:Result) -> ()){
        requestWithToken(url: "/user/\(user.id!)", method: .delete, completion: { (result) in
            guard let _ = result as? Dictionary<String, AnyObject> else { completion(.failure)  ; return }
            completion(.success)
        }) { (errorMessage, statusCode) in return controller.triggerError(errorMessage, statusCode) }
    }
    
    static func searchUser(word: String, controller: UIViewController, completion:@escaping (_ users:[User]) -> ()){
        requestWithToken(url: "/search/users/\(word)", method: .get, completion: { (result) in
            guard let dict = result as? Dictionary<String, AnyObject>, let users = dict["users"] as? [Dictionary<String, AnyObject>] else { completion([]) ; return }
            completion(User.parseArray(users))
        }) { (errorMessage, statusCode) in return controller.triggerError(errorMessage, statusCode) }
    }
    
    static func report(user: User, controller: UIViewController){
        requestWithToken(url: "/report/user/\(user.id!)", method: .put, completion: { (_) in
        }) { (errorMessage, statusCode) in return controller.triggerError(errorMessage, statusCode) }
    }
}
